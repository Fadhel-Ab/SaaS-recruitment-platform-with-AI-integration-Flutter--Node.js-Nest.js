import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service.js';
import { CreateAvailabilityDto } from './dto/create-availability.dto.js';
import { UpdateAvailabilityDto } from './dto/update-availability.dto.js';

@Injectable()
export class AvailabilityService {
  constructor(private prisma: PrismaService) {}

  async save(managerId: string, dto: CreateAvailabilityDto) {
    return this.prisma.availability.create({
      data: {
        managerId,
        ...dto,
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

    return this.prisma.availability.update({
      where: { id },
      data: dto,
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
      },
      orderBy: {
        dayOfWeek: 'asc',
      },
    });
  }
}
