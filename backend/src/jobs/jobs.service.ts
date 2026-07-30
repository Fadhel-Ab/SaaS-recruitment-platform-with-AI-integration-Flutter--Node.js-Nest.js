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
    console.log('Creating job for user:', userId);
    return this.prisma.job.create({
      data: {
        title: dto.title,

        description: dto.description,

        requirements: dto.requirements,

        employmentType: dto.employmentType,

        companyName: dto.companyName,

        skillLevel: dto.skillLevel,
        location: dto.location,

        shareToken: uuid(),

        manager: {
          connect: {
            id: userId,
          },
        },
      },
    });
  }
  async getAvailableJobs() {
    return this.prisma.job.findMany({
      where: {
        status: 'ACTIVE',
      },
      select: {
        id: true,
        title: true,
        companyName: true,
        skillLevel: true,
        status: true,

        _count: {
          select: {
            applications: true,
          },
        },

        location: true,
        employmentType: true,
        description: true,
        requirements: true,
        shareToken: true,
        createdAt: true,
      },
    });
  }
  async findMine(managerId: string) {
    return this.prisma.job.findMany({
      where: {
        managerId,
      },

      include: {
        _count: {
          select: {
            applications: true,
          },
        },
      },

      orderBy: {
        createdAt: 'desc',
      },
    });
  }
  async findByToken(token: string) {
    const job = await this.prisma.job.findUnique({
      where: {
        shareToken: token,
      },
      select: {
        id: true,
        title: true,
        description: true,
        requirements: true,
        location: true,
        employmentType: true,
        companyName: true,
        skillLevel: true,
        status: true,
        shareToken: true,
        createdAt: true,

        _count: {
          select: {
            applications: true,
          },
        },
      },
    });

    console.log('JOB FOUND:', job);

    return job;
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
