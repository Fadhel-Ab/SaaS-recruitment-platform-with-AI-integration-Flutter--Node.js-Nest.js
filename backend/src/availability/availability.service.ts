import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service.js';
import { CreateAvailabilityDto } from './dto/create-availability.dto.js';

@Injectable()
export class AvailabilityService {

  constructor(
    private prisma: PrismaService,
  ) {}


  async save(managerId: string, dto: CreateAvailabilityDto) {
  const existing = await this.prisma.availability.findFirst({
    where: { managerId },
  });

  if (existing) {
    return this.prisma.availability.update({
      where: { id: existing.id },
      data: dto,
    });
  }

  return this.prisma.availability.create({
    data: {
      managerId,
      ...dto,
    },
  });
}

async getMine(managerId: string) {
  return this.prisma.availability.findFirst({
    where: { managerId },
  });
}


  findMine(managerId:string){
    return this.prisma.availability.findMany({
      where:{
        managerId,
      },
    });
  }
}