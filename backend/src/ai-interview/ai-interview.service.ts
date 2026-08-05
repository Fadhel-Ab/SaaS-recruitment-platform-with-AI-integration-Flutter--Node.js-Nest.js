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

@Injectable()
export class AiInterviewService {
  private readonly logger = new Logger(AiInterviewService.name);

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
      // Passing the AI interview no longer auto-books a slot - the manager
      // still has to review and shortlist the candidate. Scheduling (and the
      // candidate's "you're approved" WhatsApp message) happens from
      // ApplicationsService.autoScheduleOnApproval once that happens.
      const application = await this.prisma.application.findUnique({
        where: {
          id: session.applicationId,
        },

        include: {
          candidate: true,
          job: { include: { manager: true } },
        },
      });

      if (!application) {
        throw new Error('Application not found');
      }

      await this.notifyManagerOfAiInterviewPass(application, overallScore);
    }

    return {
      interviewScore: evaluation.score,

      overallScore,

      summary: evaluation.summary,

      recommendation: evaluation.recommendation,
    };
  }

  // Soft-failed like the other Twilio side-effects: a WhatsApp hiccup should never block interview evaluation.
  private async notifyManagerOfAiInterviewPass(
    application: {
      candidate: { fullName: string };
      job: { title: string; manager: { phone: string | null } };
    },
    overallScore: number,
  ) {
    try {
      if (!application.job.manager.phone) {
        this.logger.debug(
          `Manager for job "${application.job.title}" has no phone on file - skipping AI interview pass notification`,
        );
        return;
      }

      await this.twilioService.sendWhatsApp(
        application.job.manager.phone,
        `${application.candidate.fullName} passed the AI interview for "${application.job.title}" with a score of ${overallScore}%.\n\n` +
          `Review and shortlist them in your pipeline to schedule their interview.`,
      );
    } catch (error) {
      this.logger.error(
        `Failed to notify manager of AI interview pass for application`,
        error instanceof Error ? error.stack : error,
      );
    }
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
