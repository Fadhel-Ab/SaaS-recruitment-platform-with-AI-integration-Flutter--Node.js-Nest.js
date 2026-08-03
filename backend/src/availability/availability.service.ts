import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service.js';
import { AvailabilityRecurrence } from '../generated/prisma/enums.js';
import { CreateAvailabilityDto } from './dto/create-availability.dto.js';
import { UpdateAvailabilityDto } from './dto/update-availability.dto.js';

@Injectable()
export class AvailabilityService {
  constructor(private prisma: PrismaService) {}

  private async assertOwnsJob(managerId: string, jobId: string) {
    const job = await this.prisma.job.findFirst({
      where: { id: jobId, managerId },
    });

    if (!job) {
      throw new ForbiddenException('Job not found for this manager');
    }
  }

  async save(managerId: string, dto: CreateAvailabilityDto) {
    if (dto.jobId) {
      await this.assertOwnsJob(managerId, dto.jobId);
    }

    return this.prisma.availability.create({
      data: {
        managerId,
        jobId: dto.jobId ?? null,
        recurrence: dto.recurrence,
        date: dto.recurrence === AvailabilityRecurrence.SPECIFIC ? dto.date : null,
        dayOfWeek:
          dto.recurrence === AvailabilityRecurrence.RECURRING
            ? dto.dayOfWeek
            : null,
        startTime: dto.startTime,
        endTime: dto.endTime,
      },
    });
  }

  async update(managerId: string, id: string, dto: UpdateAvailabilityDto) {
    const existing = await this.prisma.availability.findFirst({
      where: { id, managerId },
    });

    if (!existing) {
      throw new NotFoundException('Availability slot not found');
    }

    if (dto.jobId) {
      await this.assertOwnsJob(managerId, dto.jobId);
    }

    const recurrence = dto.recurrence ?? existing.recurrence;

    return this.prisma.availability.update({
      where: { id },
      data: {
        jobId: dto.jobId === undefined ? existing.jobId : dto.jobId,
        recurrence,
        date:
          recurrence === AvailabilityRecurrence.SPECIFIC
            ? (dto.date ?? existing.date)
            : null,
        dayOfWeek:
          recurrence === AvailabilityRecurrence.RECURRING
            ? (dto.dayOfWeek ?? existing.dayOfWeek)
            : null,
        startTime: dto.startTime ?? existing.startTime,
        endTime: dto.endTime ?? existing.endTime,
      },
    });
  }

  async remove(managerId: string, id: string) {
    const existing = await this.prisma.availability.findFirst({
      where: { id, managerId },
    });

    if (!existing) {
      throw new NotFoundException('Availability slot not found');
    }

    await this.prisma.availability.delete({ where: { id } });

    return { success: true };
  }

  findMine(managerId: string) {
    return this.prisma.availability.findMany({
      where: {
        managerId,
        jobId: null,
      },
      orderBy: [{ date: 'asc' }, { dayOfWeek: 'asc' }],
    });
  }
}
