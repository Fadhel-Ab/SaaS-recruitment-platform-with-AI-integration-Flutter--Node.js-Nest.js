import { Injectable, NotFoundException } from '@nestjs/common';
import { ApplicationStatus } from '../generated/prisma/enums.js';
import { CreateInterviewDto } from './dto/create-interview.dto.js';
import { Prisma } from '../generated/prisma/client.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { TwilioService } from '../twilio/twilio.service.js';

@Injectable()
export class InterviewsService {
  constructor(
    private prisma: PrismaService,
    private twilioService: TwilioService,
  ) {}

  async create(
    managerId: string,
    applicationId: string,
    dto: CreateInterviewDto,
  ) {
    const interview = await this.prisma.interview.create({
      data: {
        applicationId,

        managerId,

        scheduledAt: dto.scheduledAt ? new Date(dto.scheduledAt) : null,

        duration: dto.duration ?? 30,

        meetingLink: dto.meetingLink,
      },
    });

    await this.prisma.application.update({
      where: {
        id: applicationId,
      },

      data: {
        status: ApplicationStatus.INTERVIEW_SCHEDULED,
      },
    });

    return interview;
  }
  async startAiCall(interviewId: string) {
    const interview = await this.prisma.interview.findUnique({
      where: {
        id: interviewId,
      },
      include: {
        application: {
          include: {
            candidate: true,
          },
        },
      },
    });

    if (!interview) {
      throw new NotFoundException('Interview not found');
    }

    return this.twilioService.makeCall(
      interview.application.candidate.phone,
      interview.id,
    );
  }
}
