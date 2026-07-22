import { ConflictException, Injectable } from '@nestjs/common';
import {
  ApplicationStatus,
  InterviewStatus,
} from '../generated/prisma/enums.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { generateSlots } from './util/time-slots.js';
import { createDateFromSlot } from './util/scheduler.utils.js';
import { ConfirmScheduleDto } from './dto/confirm-schedule.dto.js';
import { Interview } from '../generated/prisma/client.js';

@Injectable()
export class SchedulingService {
  constructor(private prisma: PrismaService) {}

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

    const availability = await this.prisma.availability.findMany({
      where: {
        managerId,
      },
      orderBy: {
        dayOfWeek: 'asc',
      },
    });

    const slots: {
      dayOfWeek: number;
      time: string;
    }[] = [];

    for (const availabilitySlot of availability) {
      const generatedSlots = generateSlots(
        availabilitySlot.startTime,
        availabilitySlot.endTime,
        duration,
      );

      slots.push(
        ...generatedSlots.map((time) => ({
          dayOfWeek: availabilitySlot.dayOfWeek,
          time,
        })),
      );
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
    return this.prisma.$transaction(async (tx) => {
      const results: Interview[] = [];

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
            scheduledAt: createDateFromSlot(item.dayOfWeek, item.time),
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

        results.push(interview);
      }

      return results; // Returns an array of created interviews
    });
  }
}
