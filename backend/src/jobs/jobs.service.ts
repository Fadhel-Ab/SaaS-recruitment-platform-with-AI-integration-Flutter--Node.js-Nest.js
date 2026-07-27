import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service.js';
import { v4 as uuid } from 'uuid';
import { CreateJobDto } from './dto/create-job.dto.js';
import { StorageService } from '../common/storage/storage.service.js';

@Injectable()
export class JobsService {
  constructor(
    private prisma: PrismaService,
    private storageService: StorageService,
  ) {}

  async create(userId: string, dto: CreateJobDto) {
    return this.prisma.job.create({
      data: {
        title: dto.title,
        description: dto.description,
        requirements: dto.requirements,
        employmentType: dto.employmentType,
        managerId: userId,

        shareToken: uuid(),
      },
    });
  }

  async getAvailableJobs() {
    return this.prisma.job.findMany({
      where: {
        isActive: true,
      },
      select: {
        id: true,
        title: true,
        location: true,
        employmentType: true,
        description: true,
        requirements: true,
        shareToken: true,
        createdAt: true,
      },
      orderBy: {
        createdAt: 'desc',
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

  async getApplications(jobId: string) {
    const applications = await this.prisma.application.findMany({
      where: {
        jobId,
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

    return applications.map((application) => ({
      applicationId: application.id,

      candidateId: application.candidate.id,

      fullName: application.candidate.fullName,

      email: application.candidate.email,

      phone: application.candidate.phone,

      resumeUrl: application.candidate.resumeFileName
        ? this.storageService.getResumeUrl(application.candidate.resumeFileName)
        : null,

      overallScore: application.aiScore?.overallScore ?? null,

      cvScore: application.aiScore?.cvScore ?? null,

      interviewScore: application.aiScore?.interviewScore ?? null,

      recommendation: application.aiScore?.recommendation ?? null,

      summary: application.aiScore?.summary ?? null,

      status: application.status,

      appliedAt: application.createdAt,
    }));
  }
}
