import { Injectable, NotFoundException } from '@nestjs/common';
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

  async complete(dto: CompleteInterviewDto) {
    const session = await this.prisma.aIInterviewSession.update({
      where: {
        id: dto.sessionId,
      },
      data: {
        transcript: dto.transcript,
        completedAt: new Date(),
        status: AIInterviewStatus.COMPLETED,
      },

      include: {
        application: {
          include: {
            aiScore: true,
          },
        },
      },
    });

    const evaluation = await this.aiService.evaluateInterview(dto.transcript);

    const interviewScore =
      (evaluation.communication +
        evaluation.technical +
        evaluation.confidence +
        evaluation.problemSolving) /
      4;

    const currentScore = session.application.aiScore;

    if (!currentScore) {
      throw new Error('AI score does not exist for this application');
    }

    const overallScore = (currentScore.cvScore + interviewScore) / 2;

    const updatedScore = await this.prisma.aIScore.update({
      where: {
        applicationId: session.applicationId,
      },

      data: {
        interviewScore,

        overallScore,

        summary: evaluation.summary,
      },
    });
    await this.prisma.application.update({
      where: {
        id: session.applicationId,
      },

      data: {
        status: ApplicationStatus.INTERVIEW_COMPLETED,
      },
    });

    return {
      session,

      score: updatedScore,
    };
  }

  async startAiCall(applicationId: string) {
    console.log('call function accessed ?');
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
      this.config.get<string>('TWILIO_TEST_PHONE_NUMBER')!,
      application.id,
    );
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
}
