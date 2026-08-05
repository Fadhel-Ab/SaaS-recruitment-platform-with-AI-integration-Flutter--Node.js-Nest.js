import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service.js';

const SPARKLINE_DAYS = 7;

function bucketByDay(dates: Date[], days = SPARKLINE_DAYS): number[] {
  const buckets = new Array(days).fill(0);
  const now = new Date();
  const startOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate());

  for (const date of dates) {
    const startOfDate = new Date(date.getFullYear(), date.getMonth(), date.getDate());
    const dayDiff = Math.round(
      (startOfToday.getTime() - startOfDate.getTime()) / 86400000,
    );
    const bucketIndex = days - 1 - dayDiff;

    if (bucketIndex >= 0 && bucketIndex < days) {
      buckets[bucketIndex]++;
    }
  }

  return buckets;
}

function trendPct(dates: Date[]): number {
  const now = new Date();
  const sevenDaysAgo = new Date(now.getTime() - 7 * 86400000);
  const fourteenDaysAgo = new Date(now.getTime() - 14 * 86400000);

  const thisWeek = dates.filter((d) => d >= sevenDaysAgo && d <= now).length;
  const lastWeek = dates.filter(
    (d) => d >= fourteenDaysAgo && d < sevenDaysAgo,
  ).length;

  if (lastWeek === 0) {
    return thisWeek > 0 ? 100 : 0;
  }

  return Math.round(((thisWeek - lastWeek) / lastWeek) * 100);
}

function countYesterday(dates: Date[]): number {
  const now = new Date();
  const startOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const startOfYesterday = new Date(startOfToday.getTime() - 86400000);

  return dates.filter((d) => d >= startOfYesterday && d < startOfToday).length;
}

@Injectable()
export class DashboardService {
  constructor(private prisma: PrismaService) {}

  async getSummary(managerId: string) {
    const jobRows = await this.prisma.job.findMany({
      where: {
        managerId,
      },
      select: {
        createdAt: true,
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
        appliedAt: true,

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
        startedAt: true,
      },
    });

    // Future manager interviews
    const scheduledInterviews = await this.prisma.interview.count({
      where: {
        status: 'SCHEDULED',
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
      activeJobs: jobRows.length,

      totalApplications: applications.length,

      pendingApplications: 0,

      shortlisted: 0,

      interviewScheduled: 0,

      interviewCompleted: 0,

      withdrawn: 0,

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

      jobsTrendPct: trendPct(jobRows.map((j) => j.createdAt)),
      applicationsTrendPct: trendPct(applications.map((a) => a.appliedAt)),
      aiInterviewsYesterday: countYesterday(
        aiInterviews.filter((i) => i.startedAt).map((i) => i.startedAt!),
      ),

      jobsSparkline: bucketByDay(jobRows.map((j) => j.createdAt)),
      applicationsSparkline: bucketByDay(applications.map((a) => a.appliedAt)),
      aiInterviewsSparkline: bucketByDay(
        aiInterviews.filter((i) => i.startedAt).map((i) => i.startedAt!),
      ),
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

        case 'INTERVIEW_SCHEDULED':
          summary.interviewScheduled++;
          break;

        case 'INTERVIEW_COMPLETED':
          summary.interviewCompleted++;
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

        case 'WITHDRAWN':
          summary.withdrawn++;
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
      // cvScore/interviewScore are already stored on a 0-100 scale
      const cvPct = cand.aiScore ? Math.round(cand.aiScore.cvScore) : 0;

      const interviewScoreRaw = cand.aiScore?.interviewScore;
      const interviewPct =
        interviewScoreRaw != null ? Math.round(interviewScoreRaw) : null;

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
