import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { ApplicationStatus } from '../generated/prisma/enums.js';
import { CreateInterviewDto } from './dto/create-interview.dto.js';
import { Prisma } from '../generated/prisma/client.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { TwilioService } from '../twilio/twilio.service.js';

@Injectable()
export class InterviewsService {
  private readonly logger = new Logger(InterviewsService.name);

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

    if (interview.scheduledAt) {
      await this.notifyCandidateOfSchedule(
        applicationId,
        interview.scheduledAt,
      );
    }

    return interview;
  }

  // Soft-failed like the other Twilio side-effects: a WhatsApp hiccup should never block interview creation.
  private async notifyCandidateOfSchedule(
    applicationId: string,
    scheduledAt: Date,
  ) {
    try {
      const application = await this.prisma.application.findUnique({
        where: { id: applicationId },
        include: { candidate: true, job: true },
      });

      if (!application?.candidate.phone) {
        return;
      }

      await this.twilioService.sendInterviewScheduledMessage(
        application.candidate.phone,
        application.candidate.fullName,
        application.job.title,
        scheduledAt,
      );
    } catch (error) {
      this.logger.error(
        `Failed to notify candidate of scheduled interview for application ${applicationId}`,
        error instanceof Error ? error.stack : error,
      );
    }
  }

  async getToday(managerId: string) {
    const now = new Date();
    const startOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const endOfDay = new Date(startOfDay.getTime() + 86400000);

    const interviews = await this.prisma.interview.findMany({
      where: {
        managerId,
        scheduledAt: { gte: startOfDay, lt: endOfDay },
      },
      include: {
        application: {
          include: {
            candidate: { select: { fullName: true, email: true, phone: true } },
            job: { select: { title: true } },
          },
        },
      },
      orderBy: { scheduledAt: 'asc' },
    });

    return interviews.map((interview) => ({
      id: interview.id,
      applicationId: interview.applicationId,
      scheduledAt: interview.scheduledAt,
      duration: interview.duration,
      meetingLink: interview.meetingLink,
      status: interview.status,
      candidateName: interview.application.candidate.fullName,
      candidateEmail: interview.application.candidate.email,
      candidatePhone: interview.application.candidate.phone,
      jobTitle: interview.application.job.title,
    }));
  }
}
