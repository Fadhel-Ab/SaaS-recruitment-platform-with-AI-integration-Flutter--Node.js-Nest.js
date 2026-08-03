import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service.js';
import { v4 as uuid } from 'uuid';
import { CreateJobDto } from './dto/create-job.dto.js';
import { UpdateJobDto } from './dto/update-job.dto.js';
import { GenerateInterviewQuestionsDto } from './dto/generate-interview-questions.dto.js';
import { StorageService } from '../common/storage/storage.service.js';
import { AiService } from '../ai/ai.service.js';
import { AvailabilityRecurrence } from '../generated/prisma/enums.js';

@Injectable()
export class JobsService {
  constructor(
    private prisma: PrismaService,
    private storageService: StorageService,
    private aiService: AiService,
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
        isUrgent: dto.isUrgent ?? false,

        shareToken: uuid(),

        interviewQuestions: dto.interviewQuestions ?? [],

        manager: {
          connect: {
            id: userId,
          },
        },

        jobAvailability: {
          create: (dto.availability ?? []).map((slot) => ({
            recurrence: slot.recurrence,
            date:
              slot.recurrence === AvailabilityRecurrence.SPECIFIC && slot.date
                ? new Date(slot.date)
                : null,
            dayOfWeek:
              slot.recurrence === AvailabilityRecurrence.RECURRING
                ? slot.dayOfWeek
                : null,
            startTime: slot.startTime,
            endTime: slot.endTime,
          })),
        },
      },
    });
  }

  async update(userId: string, jobId: string, dto: UpdateJobDto) {
    const job = await this.prisma.job.findFirst({
      where: { id: jobId, managerId: userId },
    });

    if (!job) {
      throw new NotFoundException('Job not found');
    }

    return this.prisma.job.update({
      where: { id: jobId },
      data: dto,
    });
  }

  async getDefaultAvailability(managerId: string) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const upcomingOrRecurring = {
      OR: [
        { recurrence: AvailabilityRecurrence.RECURRING },
        {
          recurrence: AvailabilityRecurrence.SPECIFIC,
          date: { gte: today },
        },
      ],
    };

    const lastJob = await this.prisma.job.findFirst({
      where: { managerId },
      orderBy: { createdAt: 'desc' },
      include: {
        jobAvailability: { where: upcomingOrRecurring },
      },
    });

    if (lastJob && lastJob.jobAvailability.length > 0) {
      return lastJob.jobAvailability.map((a) => ({
        recurrence: a.recurrence,
        date: a.date,
        dayOfWeek: a.dayOfWeek,
        startTime: a.startTime,
        endTime: a.endTime,
      }));
    }

    const generalAvailability = await this.prisma.availability.findMany({
      where: { managerId, ...upcomingOrRecurring },
    });

    return generalAvailability.map((a) => ({
      recurrence: a.recurrence,
      date: a.date,
      dayOfWeek: a.dayOfWeek,
      startTime: a.startTime,
      endTime: a.endTime,
    }));
  }

  async generateInterviewQuestions(dto: GenerateInterviewQuestionsDto) {
    const questions = await this.aiService.generateInterviewQuestions(
      dto.title,
      dto.description,
      dto.requirements,
    );

    return { questions };
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
        isUrgent: true,

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

        jobAvailability: true,
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
        isUrgent: true,
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
