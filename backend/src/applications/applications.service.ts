import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  Logger,
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
import { ApplicationStatus, UserRole } from '../generated/prisma/enums.js';
import type { CurrentUserData } from '../auth/interfaces/current-user.interface.js';
import { StorageService } from '../common/storage/storage.service.js';
import { findNextAvailableSlot } from '../scheduling/util/find-next-slot.js';

@Injectable()
export class ApplicationsService {
  private readonly logger = new Logger(ApplicationsService.name);
  private readonly MIN_NOTICE_HOURS = 12;

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
      include: {
        manager: {
          select: { phone: true },
        },
      },
    });

    if (!job) {
      throw new NotFoundException('Job not found');
    }

    const isCandidateUser = currentUser?.role === UserRole.CANDIDATE;

    // A logged-in candidate always applies as themselves, even if they type
    // a different contact email on the form, so the application stays
    // attached to their account instead of fragmenting into a separate,
    // unlinked candidate profile that "My Applications" can't find.
    let candidate = isCandidateUser
      ? await this.prisma.candidate.findFirst({
          where: { userId: currentUser.id },
        })
      : null;

    const foundByAccount = !!candidate;

    if (!candidate) {
      candidate = await this.prisma.candidate.findFirst({
        where: { email: dto.email },
      });
    }

    // Only claim the userId if it's unclaimed or already ours - never steal
    // the link from a candidate profile belonging to a different account.
    const shouldLinkUser =
      isCandidateUser &&
      (!candidate?.userId || candidate.userId === currentUser.id);
    const userId = shouldLinkUser ? currentUser.id : undefined;

    candidate = candidate
      ? await this.prisma.candidate.update({
          where: { id: candidate.id },
          data: {
            fullName: dto.fullName,
            phone: dto.phone,
            resumeFileName: dto.resumeFileName,
            // A candidate can apply with whatever contact email they type,
            // but an already-linked account keeps its own email on file -
            // identity and history are tracked by account, not by which
            // email was used on any given submission.
            ...(foundByAccount ? {} : { email: dto.email }),
            ...(userId ? { userId } : {}),
          },
        })
      : await this.prisma.candidate.create({
          data: {
            fullName: dto.fullName,
            email: dto.email,
            phone: dto.phone,
            resumeFileName: dto.resumeFileName,
            ...(userId ? { userId } : {}),
          },
        });

    const existing = await this.prisma.application.findUnique({
      where: {
        candidateId_jobId: {
          candidateId: candidate.id,
          jobId: job.id,
        },
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

    await this.notifyManagerOfApplication(
      job,
      candidate.fullName,
      aiResult,
      threshold,
    );

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

  // Soft-failed like the other Twilio side-effects: a WhatsApp hiccup should never block the candidate's apply response.
  private async notifyManagerOfApplication(
    job: { title: string; manager: { phone: string | null } },
    candidateName: string,
    aiResult: { aiScore: number; shouldStartAiCall: boolean } | null,
    threshold: number,
  ) {
    try {
      if (!job.manager.phone) {
        this.logger.debug(
          `Manager for job "${job.title}" has no phone on file - skipping application WhatsApp notification`,
        );
        return;
      }

      const scoreLine = aiResult
        ? `AI Score: ${Math.round(aiResult.aiScore)}% (threshold ${threshold}%)` +
          (aiResult.shouldStartAiCall
            ? ' - qualifies for an AI phone interview.'
            : ' - did not meet the AI interview threshold.')
        : 'AI evaluation is not available yet.';

      await this.twilio.sendWhatsApp(
        job.manager.phone,
        `New application received!\n\n${candidateName} applied for "${job.title}".\n${scoreLine}`,
      );
    } catch (error) {
      this.logger.error(
        `Failed to notify manager of new application for job "${job.title}"`,
        error instanceof Error ? error.stack : error,
      );
    }
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
        this.logger.warn(
          `No AI score generated for application ${applicationId}`,
        );
        return null;
      }

      const threshold = this.getAiInterviewThreshold();

      this.logger.debug(
        `Application ${applicationId} AI score: ${aiScore.overallScore}, threshold: ${threshold}`,
      );

      if (aiScore.overallScore >= threshold) {
        this.logger.log(
          `Application ${applicationId} passed AI threshold, starting interview`,
        );

        await this.aiInterviewService.start({
          applicationId,
        });

        await this.aiInterviewService.startAiCall(applicationId);

        return { aiScore: aiScore.overallScore, shouldStartAiCall: true };
      } else {
        this.logger.log(
          `Application ${applicationId} did not pass AI threshold`,
        );
        return { aiScore: aiScore.overallScore, shouldStartAiCall: false };
      }
    } catch (error) {
      this.logger.error(
        `AI application processing failed for ${applicationId}`,
        error instanceof Error ? error.stack : error,
      );
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
    let updated = await this.prisma.application.update({
      where: {
        id: applicationId,
      },
      data: {
        status: dto.status,
      },
    });

    if (dto.status === ApplicationStatus.SHORTLISTED) {
      const scheduled = await this.autoScheduleOnApproval(applicationId);

      if (scheduled) {
        updated = await this.prisma.application.findUniqueOrThrow({
          where: { id: applicationId },
        });
      }
    }

    return updated;
  }

  async bulkUpdateStatus(
    managerId: string,
    applicationIds: string[],
    status: ApplicationStatus,
  ) {
    const applications = await this.prisma.application.findMany({
      where: {
        id: { in: applicationIds },
        job: { managerId },
      },
    });

    const updated: string[] = [];
    const skipped: string[] = [];

    for (const application of applications) {
      if (allowedTransitions[application.status].includes(status)) {
        await this.prisma.application.update({
          where: { id: application.id },
          data: { status },
        });
        updated.push(application.id);

        if (status === ApplicationStatus.SHORTLISTED) {
          await this.autoScheduleOnApproval(application.id);
        }
      } else {
        skipped.push(application.id);
      }
    }

    return { updated, skipped };
  }

  /**
   * Auto-books the next available interview slot once a manager shortlists a
   * candidate, respecting a minimum notice window, and notifies the
   * candidate over WhatsApp. Side-effects are soft-failed (logged, not
   * thrown) so a Twilio/scheduling hiccup never blocks the status change
   * itself. Returns whether an interview was actually created.
   */
  private async autoScheduleOnApproval(
    applicationId: string,
  ): Promise<boolean> {
    try {
      const application = await this.prisma.application.findUnique({
        where: { id: applicationId },
        include: { candidate: true, job: true, interview: true },
      });

      if (!application || application.interview) {
        return false;
      }

      const scheduledAt = await findNextAvailableSlot(this.prisma, {
        jobId: application.job.id,
        managerId: application.job.managerId,
        minNoticeHours: this.MIN_NOTICE_HOURS,
      });

      await this.prisma.$transaction(async (tx) => {
        await tx.interview.create({
          data: {
            applicationId: application.id,
            managerId: application.job.managerId,
            status: 'SCHEDULED',
            scheduledAt,
            duration: 30,
          },
        });

        await tx.application.update({
          where: { id: application.id },
          data: { status: ApplicationStatus.INTERVIEW_SCHEDULED },
        });
      });

      if (application.candidate.phone) {
        const formatted = scheduledAt.toLocaleString('en-US', {
          weekday: 'long',
          month: 'long',
          day: 'numeric',
          hour: 'numeric',
          minute: '2-digit',
        });

        await this.twilio.sendWhatsApp(
          application.candidate.phone,
          `Hi ${application.candidate.fullName}, great news! You've been shortlisted for "${application.job.title}".\n\n` +
            `Your interview is scheduled for ${formatted}. We'll follow up with more details soon.`,
        );
      }

      return true;
    } catch (error) {
      this.logger.error(
        `Auto-scheduling failed for application ${applicationId}`,
        error instanceof Error ? error.stack : error,
      );
      return false;
    }
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

    return Promise.all(
      applications.map(async (application) => ({
        ...application,
        candidate: {
          ...application.candidate,
          resumeUrl: application.candidate.resumeFileName
            ? await this.storageService.getResumeUrl(
                application.candidate.resumeFileName,
              )
            : null,
        },
      })),
    );
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
          ? await this.storageService.getResumeUrl(
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

  // Prefills the application form: candidate profile if they've applied before, else account details.
  async getMyProfile(userId: string, email: string) {
    const candidate = await this.prisma.candidate.findFirst({
      where: { userId },
    });

    if (candidate) {
      return {
        fullName: candidate.fullName,
        email: candidate.email,
        phone: candidate.phone,
      };
    }

    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { fullName: true, email: true, phone: true },
    });

    return {
      fullName: user?.fullName ?? '',
      email: user?.email ?? email,
      phone: user?.phone ?? '',
    };
  }
}
