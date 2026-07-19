import { Injectable } from '@nestjs/common';
import { PrismaService } from 'prisma/prisma.service.js';
import { v4 as uuid } from 'uuid';
import { CreateJobDto } from './dto/create-job.dto.js';

@Injectable()
export class JobsService {
  constructor(private prisma: PrismaService) {}

  async create(userId: string, dto: CreateJobDto) {
    return this.prisma.job.create({
      data: {
        title: dto.title,
        description: dto.description,
        requirements: dto.requirements,

        managerId: userId,

        shareToken: uuid(),
      },
    });
  }
  async findMine(userId: string) {
    return this.prisma.job.findMany({
      where: {
        managerId: userId,
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  async findByToken(token: string) {
  return this.prisma.job.findUnique({
    where: {
      shareToken: token,
    },
  });
}
}
