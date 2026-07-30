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

    return summary;
  }
}
