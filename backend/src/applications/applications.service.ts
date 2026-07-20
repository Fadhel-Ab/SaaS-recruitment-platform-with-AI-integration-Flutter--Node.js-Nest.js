import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service.js';
import { CreateApplicationDto } from './dto/create-application.dto.js';
import { AiService } from '../ai/ai.service.js';

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
    // AI will be called here

    return application;
  }
}
