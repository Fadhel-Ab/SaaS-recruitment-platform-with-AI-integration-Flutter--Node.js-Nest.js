import {
  ConflictException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import {
  ApplicationStatus,
  InterviewStatus,
} from '../generated/prisma/enums.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { generateSlots } from './util/time-slots.js';
import { createDateFromSlot } from './util/scheduler.utils.js';
import { expandAvailabilityWindows } from './util/expand-availability-windows.js';
import { ConfirmScheduleDto } from './dto/confirm-schedule.dto.js';
import { Interview } from '../generated/prisma/client.js';
import { TwilioService } from '../twilio/twilio.service.js';

@Injectable()
export class SchedulingService {
  private readonly logger = new Logger(SchedulingService.name);

  constructor(
    private prisma: PrismaService,
    private twilioService: TwilioService,
  ) {}

  async generate(managerId: string, jobId: string, duration: number) {
    const applications = await this.prisma.application.findMany({
      where: {
        jobId,
        status: ApplicationStatus.SHORTLISTED,
      },
      include: {
        candidate: true,
        aiScore: true,
      },
      orderBy: {
        aiScore: {
          overallScore: 'desc',
        },
      },
    });

    const job = await this.prisma.job.findFirst({
      where: { id: jobId, managerId },
      include: { jobAvailability: true },
    });

    if (!job) {
      throw new NotFoundException('Job not found');
    }

    const availability =
      job.jobAvailability.length > 0
        ? job.jobAvailability
        : await this.prisma.availability.findMany({
            where: { managerId, jobId: null },
          });

    const windows = expandAvailabilityWindows(availability);

    const existingInterviews = await this.prisma.interview.findMany({
      where: {
        managerId,
        status: InterviewStatus.SCHEDULED,
        scheduledAt: { not: null },
      },
    });

    const busyRanges = existingInterviews.map((interview) => {
      const start = interview.scheduledAt!.getTime();
      return { start, end: start + interview.duration * 60000 };
    });

    const slots: {
      date: Date;
      time: string;
    }[] = [];

    for (const window of windows) {
      const generatedSlots = generateSlots(
        window.startTime,
        window.endTime,
        duration,
      );

      for (const time of generatedSlots) {
        const start = createDateFromSlot(window.date, time).getTime();
        const end = start + duration * 60000;
        const conflicts = busyRanges.some(
          (range) => start < range.end && end > range.start,
        );

        if (!conflicts) {
          slots.push({ date: window.date, time });
        }
      }
    }

    return applications.map((application, index) => ({
      applicationId: application.id,

      candidateId: application.candidate.id,

      candidateName: application.candidate.fullName,

      score: application.aiScore?.overallScore ?? null,

      duration,

      slot: slots[index] ?? null,
    }));
  }

  async confirm(managerId: string, dto: ConfirmScheduleDto) {
    // 1. Wrap EVERYTHING in a single transaction block
    const results = await this.prisma.$transaction(async (tx) => {
      const created: Interview[] = [];

      // 2. Loop sequentially so checks happen one after the other safely
      for (const item of dto.interviews) {
        // CRITICAL: Use 'tx', NOT 'this.prisma' inside the transaction block!
        const existingInterview = await tx.interview.findUnique({
          where: {
            applicationId: item.applicationId,
          },
        });

        if (existingInterview) {
          throw new ConflictException(
            `Interview already exists for application ${item.applicationId}`,
          );
        }

        // 3. Create the interview using 'tx'
        const interview = await tx.interview.create({
          data: {
            applicationId: item.applicationId,
            managerId,
            scheduledAt: createDateFromSlot(item.date, item.time),
            duration: dto.duration,
            status: InterviewStatus.SCHEDULED,
          },
        });

        // 4. Update the application status using 'tx'
        await tx.application.update({
          where: {
            id: item.applicationId,
          },
          data: {
            status: ApplicationStatus.INTERVIEW_SCHEDULED,
          },
        });

        created.push(interview);
      }

      return created; // Returns an array of created interviews
    });

    // Notified outside the transaction so a slow/failed WhatsApp send never
    // holds the DB transaction open or rolls back interviews that were
    // already committed.
    await this.notifyCandidatesOfSchedule(results);

    return results;
  }

  private async notifyCandidatesOfSchedule(interviews: Interview[]) {
    for (const interview of interviews) {
      try {
        if (!interview.scheduledAt) {
          continue;
        }

        const application = await this.prisma.application.findUnique({
          where: { id: interview.applicationId },
          include: { candidate: true, job: true },
        });

        if (!application?.candidate.phone) {
          continue;
        }

        await this.twilioService.sendInterviewScheduledMessage(
          application.candidate.phone,
          application.candidate.fullName,
          application.job.title,
          interview.scheduledAt,
        );
      } catch (error) {
        this.logger.error(
          `Failed to notify candidate of scheduled interview for application ${interview.applicationId}`,
          error instanceof Error ? error.stack : error,
        );
      }
    }
  }
}
