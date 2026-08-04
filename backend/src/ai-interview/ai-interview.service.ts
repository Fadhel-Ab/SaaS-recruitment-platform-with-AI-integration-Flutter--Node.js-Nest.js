import {
  forwardRef,
  Inject,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service.js';
import { StartInterviewDto } from './dto/start_interview.dto.js';
import {
  AIInterviewStatus,
  ApplicationStatus,
} from '../generated/prisma/enums.js';
import { CompleteInterviewDto } from './dto/complete_interview.dto.js';
import { AiService } from '../ai/ai.service.js';
import { TwilioService } from '../twilio/twilio.service.js';
import { ConfigService } from '@nestjs/config';
import { expandAvailabilityWindows } from '../scheduling/util/expand-availability-windows.js';

@Injectable()
export class AiInterviewService {
  private readonly logger = new Logger(AiInterviewService.name);
  private readonly SLOT_DURATION_MINUTES = 30;

  constructor(
    private prisma: PrismaService,
    private aiService: AiService,
    @Inject(forwardRef(() => TwilioService))
    private twilioService: TwilioService,
    private config: ConfigService,
  ) {}

  /**
   * Finds the next free interview slot for a manager, preferring the job's
   * own availability windows and falling back to the manager's general
   * availability, then to "tomorrow" if neither is configured. Availability
   * windows can be recurring weekdays or one-off calendar dates; both are
   * expanded into concrete dated occurrences and walked in order, checking
   * against already-booked interviews for that manager so two candidates
   * never land on the same time.
   */
  private async findNextAvailableSlot(
    jobId: string,
    managerId: string,
  ): Promise<Date> {
    const now = new Date();

    const jobWindows = await this.prisma.availability.findMany({
      where: { jobId },
    });

    let windows = expandAvailabilityWindows(jobWindows, { from: now });

    if (windows.length === 0) {
      const managerWindows = await this.prisma.availability.findMany({
        where: { managerId, jobId: null },
      });

      windows = expandAvailabilityWindows(managerWindows, { from: now });
    }

    const fallbackTomorrow = () => {
      const fallback = new Date();
      fallback.setDate(fallback.getDate() + 1);
      return fallback;
    };

    if (windows.length === 0) {
      return fallbackTomorrow();
    }

    const horizon = windows.reduce(
      (latest, w) => (w.date > latest ? w.date : latest),
      windows[0].date,
    );

    const existingInterviews = await this.prisma.interview.findMany({
      where: {
        managerId,
        status: { not: 'CANCELLED' },
        scheduledAt: { gte: now, lte: horizon },
      },
      select: { scheduledAt: true },
    });

    const taken = new Set(
      existingInterviews
        .filter((i) => i.scheduledAt)
        .map((i) => i.scheduledAt!.getTime()),
    );

    for (const window of windows) {
      const [startHour, startMinute] = window.startTime.split(':').map(Number);
      const [endHour, endMinute] = window.endTime.split(':').map(Number);

      const windowStart = new Date(window.date);
      windowStart.setHours(startHour, startMinute, 0, 0);

      const windowEnd = new Date(window.date);
      windowEnd.setHours(endHour, endMinute, 0, 0);

      const slot = new Date(windowStart);

      while (
        slot.getTime() + this.SLOT_DURATION_MINUTES * 60000 <=
        windowEnd.getTime()
      ) {
        if (slot.getTime() > now.getTime() && !taken.has(slot.getTime())) {
          return new Date(slot);
        }

        slot.setMinutes(slot.getMinutes() + this.SLOT_DURATION_MINUTES);
      }
    }

    return fallbackTomorrow();
  }

  async start(dto: StartInterviewDto) {
    const application = await this.prisma.application.findUnique({
      where: {
        id: dto.applicationId,
      },
      include: {
        aiInterview: true,
      },
    });

    if (!application) {
      throw new NotFoundException('Application not found');
    }

    if (application.aiInterview) {
      return application.aiInterview;
    }

    return this.prisma.aIInterviewSession.create({
      data: {
        applicationId: application.id,
        status: AIInterviewStatus.IN_PROGRESS,
        startedAt: new Date(),
      },
    });
  }
  async complete(sessionId: string, transcript: string) {
    const session = await this.prisma.aIInterviewSession.findUnique({
      where: {
        id: sessionId,
      },
    });

    if (!session) {
      throw new Error('Interview session not found');
    }

    await this.prisma.aIInterviewSession.update({
      where: {
        id: sessionId,
      },

      data: {
        transcript,
        status: AIInterviewStatus.COMPLETED,
        completedAt: new Date(),
      },
    });

    this.logger.log(`Evaluating AI interview transcript for session ${sessionId}`);

    const evaluation = await this.aiService.evaluateInterview(transcript);

    this.logger.debug(`Interview evaluation score: ${evaluation.score}`);

    const aiScore = await this.prisma.aIScore.findUnique({
      where: {
        applicationId: session.applicationId,
      },
    });

    if (!aiScore) {
      throw new Error('CV AI score not found');
    }

    const overallScore = Math.round((aiScore.cvScore + evaluation.score) / 2);

    this.logger.log(`Final overall score for application ${session.applicationId}: ${overallScore}`);

    await this.prisma.aIScore.update({
      where: {
        applicationId: session.applicationId,
      },

      data: {
        interviewScore: evaluation.score,
        overallScore,
        summary: evaluation.summary,
        recommendation: evaluation.recommendation,
      },
    });

    const threshold = this.config.get<number>('AI_INTERVIEW_THRESHOLD', 60);

    if (overallScore >= threshold) {
      const application = await this.prisma.application.findUnique({
        where: {
          id: session.applicationId,
        },

        include: {
          candidate: true,
          job: true,
        },
      });

      if (!application) {
        throw new Error('Application not found');
      }

      const scheduledAt = await this.findNextAvailableSlot(
        application.job.id,
        application.job.managerId,
      );

      await this.prisma.interview.create({
        data: {
          applicationId: session.applicationId,

          managerId: application.job.managerId,

          status: 'SCHEDULED',

          scheduledAt,

          duration: 30,
        },
      });

      if (application.candidate.phone) {
        await this.twilioService.sendWhatsApp(
          application.candidate.phone,

          `Hello ${application.candidate.fullName}, congratulations!

You have passed our AI interview.

Your final score: ${overallScore}%.

We will contact you regarding the next interview step.`,
        );
      }
    }

    return {
      interviewScore: evaluation.score,

      overallScore,

      summary: evaluation.summary,

      recommendation: evaluation.recommendation,
    };
  }

  async saveAnswer(applicationId: string, answer: string) {
    const session = await this.prisma.aIInterviewSession.findUnique({
      where: {
        applicationId,
      },
    });

    if (!session) {
      throw new NotFoundException('Interview session not found');
    }

    return this.prisma.aIInterviewSession.update({
      where: {
        applicationId,
      },

      data: {
        transcript: `${session.transcript ?? ''}\nCandidate: ${answer}`,

        questionCount: {
          increment: 1,
        },
      },
    });
  }
  async saveQuestion(applicationId: string, question: string) {
    const session = await this.prisma.aIInterviewSession.findUnique({
      where: {
        applicationId,
      },
    });

    if (!session) {
      throw new NotFoundException('Interview session not found');
    }

    return this.prisma.aIInterviewSession.update({
      where: {
        applicationId,
      },

      data: {
        transcript: `${session.transcript ?? ''}\nInterviewer: ${question}`,
      },
    });
  }
  async startAiCall(applicationId: string) {
    const application = await this.prisma.application.findUnique({
      where: {
        id: applicationId,
      },
      include: {
        candidate: true,
      },
    });

    if (!application) {
      throw new NotFoundException('Application not found');
    }

    return this.twilioService.makeCall(
      this.config.get<string>('TWILIO_TEST_PHONE_NUMBER') ??
        application.candidate.phone,
      application.id,
    );
  }
  async getInterviewPlan(applicationId: string): Promise<string[]> {
    const application = await this.prisma.application.findUnique({
      where: {
        id: applicationId,
      },
      include: {
        job: true,
      },
    });

    return application?.job.interviewQuestions ?? [];
  }
  async findLatestApplicationByPhone(phone: string) {
    return this.prisma.application.findFirst({
      where: {
        candidate: {
          phone,
        },
      },
      orderBy: {
        appliedAt: 'desc',
      },
    });
  }
  async getApplication(applicationId: string) {
    return this.prisma.application.findUnique({
      where: {
        id: applicationId,
      },
      include: {
        candidate: true,
        job: true,
      },
    });
  }
}
