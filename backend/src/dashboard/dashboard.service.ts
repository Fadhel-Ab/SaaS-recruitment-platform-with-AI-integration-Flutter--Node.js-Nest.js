import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service.js';

@Injectable()
export class DashboardService {
  constructor(private prisma: PrismaService) {}

  async getSummary(managerId: string) {
    const jobs = await this.prisma.job.count({
      where: {
        managerId,
      },
    });

    const applications = await this.prisma.application.findMany({
      where: {
        job: {
          managerId,
        },
      },

      select: {
        status: true,

        aiScore: {
          select: {
            overallScore: true,
          },
        },
      },
    });

    // AI phone interviews
    const aiInterviews = await this.prisma.aIInterviewSession.findMany({
      where: {
        application: {
          job: {
            managerId,
          },
        },
      },

      select: {
        status: true,
      },
    });

    // Future manager interviews
    const scheduledInterviews = await this.prisma.interview.count({
      where: {
        application: {
          job: {
            managerId,
          },
        },
      },
    });

    const completedInterviews = await this.prisma.interview.count({
      where: {
        status: 'COMPLETED',

        application: {
          job: {
            managerId,
          },
        },
      },
    });

    const summary = {
      activeJobs: jobs,

      totalApplications: applications.length,

      pendingApplications: 0,

      shortlisted: 0,

      // AI interviews
      aiInterviews: aiInterviews.length,

      completedAIInterviews: 0,

      // Manager interviews
      scheduledInterviews,

      completedInterviews,

      offers: 0,

      hired: 0,

      rejected: 0,

      averageAIScore: 0,
    };

    let totalScore = 0;
    let scoredCandidates = 0;

    // AI interview completion count
    for (const interview of aiInterviews) {
      if (interview.status === 'COMPLETED') {
        summary.completedAIInterviews++;
      }
    }

    // Application pipeline
    for (const application of applications) {
      switch (application.status) {
        case 'PENDING':
          summary.pendingApplications++;
          break;

        case 'SHORTLISTED':
          summary.shortlisted++;
          break;

        case 'OFFERED':
          summary.offers++;
          break;

        case 'HIRED':
          summary.hired++;
          break;

        case 'REJECTED':
          summary.rejected++;
          break;
      }

      if (application.aiScore) {
        totalScore += application.aiScore.overallScore;
        scoredCandidates++;
      }
    }

    summary.averageAIScore =
      scoredCandidates === 0
        ? 0
        : Number((totalScore / scoredCandidates).toFixed(2));
    const topCandidatesRaw = await this.prisma.application.findMany({
      where: {
        job: { managerId },
        aiScore: { isNot: null },
      },
      take: 5,
      orderBy: {
        aiScore: {
          overallScore: 'desc',
        },
      },
      select: {
        id: true,

        candidate: {
          select: {
            fullName: true,
          },
        },

        job: {
          select: {
            title: true,
          },
        },

        aiScore: {
          select: {
            cvScore: true,
            interviewScore: true,
            overallScore: true,
            summary: true,
          },
        },
      },
    });
    // Format clean, frontend-ready models
    const topCandidates = topCandidatesRaw.map((cand) => {
      // Map decimals (e.g. 0.85) to percentages (85) safely
      const cvPct = cand.aiScore ? Math.round(cand.aiScore.cvScore * 100) : 0;

      const interviewScoreRaw = cand.aiScore?.interviewScore;
      const interviewPct =
        interviewScoreRaw != null ? Math.round(interviewScoreRaw * 100) : null;

      return {
        id: cand.id,
        name: cand.candidate.fullName,
        role: cand.job.title,
        cvScore: cvPct,
        interviewScore: interviewPct,
        // Fall back to schema summary if available, otherwise apply a default string rule
        summary:
          cand.aiScore?.summary ||
          (interviewPct
            ? `Outstanding CV match (${cvPct}%) with strong verbal performance (${interviewPct}%).`
            : `High potential profile match (${cvPct}%). Screening pending.`),
      };
    });

    return {
      ...summary,
      topCandidates,
    };
  }
}
