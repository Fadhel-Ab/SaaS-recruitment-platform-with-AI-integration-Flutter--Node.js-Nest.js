import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service.js';
import { StartInterviewDto } from './dto/start_interview.dto.js';
import { AIInterviewStatus } from '../generated/prisma/enums.js';
import { CompleteInterviewDto } from './dto/complete_interview.dto.js';
import { AiService } from '../ai/ai.service.js';
@Injectable()
export class AiInterviewService {
  constructor(
    private prisma: PrismaService,
    private aiService: AiService,
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
    const session =
      await this.prisma.aIInterviewSession.update({
        where: {
          id: dto.sessionId,
        },
        data: {
          transcript: dto.transcript,
          completedAt: new Date(),
          status: AIInterviewStatus.COMPLETED,
        },
      });

    const evaluation =
      await this.aiService.evaluateInterview(
        dto.transcript,
      );

    console.log(evaluation);

    return {
      session,
      evaluation,
    };
  }
}
