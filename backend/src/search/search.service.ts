import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service.js';

const MAX_RESULTS = 5;

@Injectable()
export class SearchService {
  constructor(private prisma: PrismaService) {}

  async search(managerId: string, query: string) {
    const q = query.trim();

    if (!q) {
      return { jobs: [], candidates: [] };
    }

    const jobs = await this.prisma.job.findMany({
      where: {
        managerId,
        title: { contains: q, mode: 'insensitive' },
      },
      take: MAX_RESULTS,
      select: {
        id: true,
        title: true,
        companyName: true,
      },
    });

    const applications = await this.prisma.application.findMany({
      where: {
        job: { managerId },
        candidate: {
          OR: [
            { fullName: { contains: q, mode: 'insensitive' } },
            { email: { contains: q, mode: 'insensitive' } },
          ],
        },
      },
      take: MAX_RESULTS,
      select: {
        id: true,
        candidate: {
          select: {
            fullName: true,
            email: true,
          },
        },
        job: {
          select: {
            title: true,
          },
        },
      },
    });

    return {
      jobs: jobs.map((j) => ({
        id: j.id,
        title: j.title,
        companyName: j.companyName,
      })),
      candidates: applications.map((a) => ({
        applicationId: a.id,
        name: a.candidate.fullName,
        email: a.candidate.email,
        jobTitle: a.job.title,
      })),
    };
  }
}
