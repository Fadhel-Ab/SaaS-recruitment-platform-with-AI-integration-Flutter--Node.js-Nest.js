import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service.js';
import { CreateApplicationDto } from './dto/create-application.dto.js';
import { AiService } from '../ai/ai.service.js';
import { UpdateApplicationStatusDto } from './dto/update-application-status.dto.js';
import { allowedTransitions } from './utils/status-transition.js';

@Injectable()
export class ApplicationsService {
  constructor(
    private prisma: PrismaService,
    private aiService: AiService,
  ) {}

  async apply(shareToken: string, dto: CreateApplicationDto) {
    const job = await this.prisma.job.findUnique({
      where: {
        shareToken,
      },
    });

    if (!job) {
      throw new NotFoundException('Job not found');
    }

    let candidate = await this.prisma.candidate.findFirst({
      where: {
        email: dto.email,
      },
    });

    if (!candidate) {
      candidate = await this.prisma.candidate.create({
        data: {
          fullName: dto.fullName,
          email: dto.email,
          phone: dto.phone,
          resumeFileName: dto.resumeFileName,
        },
      });
    } else {
      candidate = await this.prisma.candidate.update({
        where: {
          id: candidate.id,
        },
        data: {
          fullName: dto.fullName,
          phone: dto.phone,
          resumeFileName: dto.resumeFileName,
        },
      });
    }

    const existing = await this.prisma.application.findFirst({
      where: {
        candidateId: candidate.id,
        jobId: job.id,
      },
    });

    if (existing) {
      throw new ConflictException('Already applied to this job');
    }
    const application = await this.prisma.application.create({
      data: {
        candidateId: candidate.id,
        jobId: job.id,
      },
    });
    await this.aiService.processApplication(application.id);

    return application;
  }

  async updateStatus(applicationId: string, dto: UpdateApplicationStatusDto) {
    const application = await this.prisma.application.findUnique({
      where: {
        id: applicationId,
      },
    });

    if (!application) {
      throw new NotFoundException('Application not found');
    }
    if (!allowedTransitions[application.status].includes(dto.status)) {
      throw new BadRequestException('Invalid status transition');
    }
    return this.prisma.application.update({
      where: {
        id: applicationId,
      },
      data: {
        status: dto.status,
      },
    });
  }
  async getJobApplications(jobId: string) {
    return this.prisma.application.findMany({
      where: {
        jobId,
      },

      include: {
        candidate: {
          select: {
            id: true,
            fullName: true,
            email: true,
            phone: true,
          },
        },

        aiScore: true,

        aiInterview: true,
      },

      orderBy: {
        aiScore: {
          overallScore: 'desc',
        },
      },
    });
  }
  async getApplicationDetails(applicationId: string) {
    const application = await this.prisma.application.findUnique({
      where: {
        id: applicationId,
      },

      include: {
        candidate: {
          select: {
            id: true,
            fullName: true,
            email: true,
            phone: true,
            resumeFileName: true,
          },
        },

        job: {
          select: {
            id: true,
            title: true,
          },
        },

        aiScore: true,

        aiInterview: true,

        interview: true,
      },
    });

    if (!application) {
      throw new NotFoundException('Application not found');
    }

    return application;
  }
}
