import {
  forwardRef,
  Inject,
  Injectable,
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
@Injectable()
export class AiInterviewService {
  constructor(
    private prisma: PrismaService,
    private aiService: AiService,
    @Inject(forwardRef(() => TwilioService))
    private twilioService: TwilioService,
    private config: ConfigService,
  ) {}

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

    console.log('Evaluating AI interview transcript...');

    const evaluation = await this.aiService.evaluateInterview(transcript);

    console.log('Interview evaluation:', evaluation);

    const aiScore = await this.prisma.aIScore.findUnique({
      where: {
        applicationId: session.applicationId,
      },
    });

    if (!aiScore) {
      throw new Error('CV AI score not found');
    }

    const overallScore = Math.round((aiScore.cvScore + evaluation.score) / 2);

    console.log('FINAL SCORE:', overallScore);

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
      const availability = await this.prisma.availability.findFirst({
        where: {
          managerId: application.job.managerId,
        },
      });

      const scheduledAt = new Date();

      if (availability) {
        const today = scheduledAt.getDay(); // Sunday = 0

        // Convert stored 1-7 (Mon-Sun) to JS 0-6 (Sun-Sat)
        const targetDay = availability.dayOfWeek % 7;

        let daysUntil = targetDay - today;

        if (daysUntil <= 0) {
          daysUntil += 7;
        }

        scheduledAt.setDate(scheduledAt.getDate() + daysUntil);

        const parts = availability.startTime.split(':');

        scheduledAt.setHours(Number(parts[0]), Number(parts[1]), 0, 0);
      } else {
        scheduledAt.setDate(scheduledAt.getDate() + 1);
      }
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
