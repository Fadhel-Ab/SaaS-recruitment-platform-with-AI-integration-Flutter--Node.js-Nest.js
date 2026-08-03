import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service.js';
import { CreateApplicationDto } from './dto/create-application.dto.js';
import { AiService } from '../ai/ai.service.js';
import { UpdateApplicationStatusDto } from './dto/update-application-status.dto.js';
import { allowedTransitions } from './utils/status-transition.js';
import { TwilioService } from '../twilio/twilio.service.js';
import { AiInterviewService } from '../ai-interview/ai-interview.service.js';
import { UserRole } from '../generated/prisma/enums.js';
import type { CurrentUserData } from '../auth/interfaces/current-user.interface.js';
import { StorageService } from '../common/storage/storage.service.js';

@Injectable()
export class ApplicationsService {
  constructor(
    private prisma: PrismaService,
    private aiService: AiService,
    private twilio: TwilioService,
    private aiInterviewService: AiInterviewService,
    private config: ConfigService,
    private storageService: StorageService,
  ) {}
  async apply(
    shareToken: string,
    dto: CreateApplicationDto,
    currentUser?: CurrentUserData,
  ) {
    if (currentUser?.role === UserRole.MANAGER) {
      throw new ForbiddenException(
        'Managers cannot apply to jobs. Please use a candidate account.',
      );
    }
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

    if (
      currentUser?.role === UserRole.CANDIDATE &&
      !candidate.userId
    ) {
      candidate = await this.prisma.candidate.update({
        where: {
          id: candidate.id,
        },
        data: {
          userId: currentUser.id,
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
      include: {
        candidate: true,
        job: true,
      },
    });

    const aiResult = await this.processApplicationAI(application.id);
    const threshold = this.getAiInterviewThreshold();

    return {
      applicationId: application.id,
      status: application.status,
      message: aiResult?.shouldStartAiCall
        ? 'Application submitted successfully. AI call is ready.'
        : 'Application submitted successfully. AI evaluation completed.',
      aiScore: aiResult?.aiScore ?? null,
      threshold,
      shouldStartAiCall: aiResult?.shouldStartAiCall ?? false,
    };
  }
  private getAiInterviewThreshold() {
    return this.config.get<number>('AI_INTERVIEW_THRESHOLD', 60);
  }

  private async processApplicationAI(applicationId: string) {
    try {
      await this.aiService.processApplication(applicationId);

      const aiScore = await this.prisma.aIScore.findUnique({
        where: {
          applicationId,
        },
      });

      if (!aiScore) {
        console.log('No AI score generated for:', applicationId);
        return null;
      }

      const threshold = this.getAiInterviewThreshold();

      console.log(`AI score: ${aiScore.overallScore}, threshold: ${threshold}`);

      if (aiScore.overallScore >= threshold) {
        console.log(
          'Candidate passed AI threshold, starting interview:',
          applicationId,
        );

        await this.aiInterviewService.start({
          applicationId,
        });

        await this.aiInterviewService.startAiCall(applicationId);

        return { aiScore: aiScore.overallScore, shouldStartAiCall: true };
      } else {
        console.log('Candidate did not pass AI threshold:', applicationId);
        return { aiScore: aiScore.overallScore, shouldStartAiCall: false };
      }
    } catch (error) {
      console.error('AI application processing failed:', error);
      return null;
    }
  }
  async updateStatus(
    managerId: string,
    applicationId: string,
    dto: UpdateApplicationStatusDto,
  ) {
    const application = await this.prisma.application.findUnique({
      where: {
        id: applicationId,
        job: {
          managerId,
        },
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
  async getJobApplications(managerId: string, jobId: string) {
    const job = await this.prisma.job.findFirst({
      where: {
        id: jobId,
        managerId,
      },
    });

    if (!job) {
      throw new NotFoundException('Job not found');
    }
    const applications = await this.prisma.application.findMany({
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
            resumeFileName: true,
          },
        },

        aiScore: true,

        aiInterview: true,
      },

      orderBy: {
        appliedAt: 'desc',
      },
    });

    return applications.map((application) => ({
      ...application,
      candidate: {
        ...application.candidate,
        resumeUrl: application.candidate.resumeFileName
          ? this.storageService.getResumeUrl(
              application.candidate.resumeFileName,
            )
          : null,
      },
    }));
  }
  async getApplicationDetails(managerId: string, applicationId: string) {
    const application = await this.prisma.application.findUnique({
      where: {
        id: applicationId,
        job: {
          managerId,
        },
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

    return {
      ...application,
      candidate: {
        ...application.candidate,
        resumeUrl: application.candidate.resumeFileName
          ? this.storageService.getResumeUrl(
              application.candidate.resumeFileName,
            )
          : null,
      },
    };
  }

  async getPipeline(managerId: string) {
    const applications = await this.prisma.application.findMany({
      where: {
        job: {
          managerId,
        },
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

        job: {
          select: {
            id: true,
            title: true,
          },
        },

        aiScore: true,

        aiInterview: true,
      },

      orderBy: {
        appliedAt: 'desc',
      },
    });

    return applications;
  }

  async getMyApplications(userId: string, email: string) {
    let candidate = await this.prisma.candidate.findFirst({
      where: {
        OR: [{ userId }, { email }],
      },
    });

    if (!candidate) {
      return [];
    }

    if (!candidate.userId) {
      candidate = await this.prisma.candidate.update({
        where: {
          id: candidate.id,
        },
        data: {
          userId,
        },
      });
    }

    return this.prisma.application.findMany({
      where: {
        candidateId: candidate.id,
      },

      include: {
        job: {
          select: {
            title: true,
            companyName: true,
            location: true,
          },
        },

        aiScore: true,

        interview: true,
      },

      orderBy: {
        appliedAt: 'desc',
      },
    });
  }
}
