import { Injectable } from '@nestjs/common';
import { AIProviderService } from './ai.provider.service.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { ResumeParserService } from './resume-parser.service.js';
import { StorageService } from '../common/storage/storage.service.js';

@Injectable()
export class AiService {
  constructor(
    private prisma: PrismaService,
    private parser: ResumeParserService,
    private aiProvider: AIProviderService,
    private storage: StorageService,
  ) {}

  async processApplication(applicationId: string) {
    const application = await this.prisma.application.findUnique({
      where: {
        id: applicationId,
      },
      include: {
        candidate: true,
        job: true,
      },
    });

    if (!application || !application.candidate.resumeFileName) {
      throw new Error(
        'Application or candidate resume path could not be found.',
      );
    }

    const filePath = this.storage.getResumePath(
      application.candidate.resumeFileName,
    );

    // 1. Convert resume file to plain text
    const resumeText = await this.parser.extractText(filePath);

    // 2. Fetch the strict JSON response object from the API service
    const analysis = await this.aiProvider.analyzeResume(
      resumeText,
      application.job.description,
    );

    // 3. Map values directly to your database fields
    await this.prisma.aIScore.create({
      data: {
        applicationId: application.id,
        cvScore: analysis.score,
        overallScore: analysis.score,
        strengths: analysis.strengths,
        weaknesses: analysis.weaknesses,
        summary: analysis.summary,
        recommendation: analysis.recommendation,
      },
    });

    return analysis;
  }
  async evaluateInterview(transcript: string) {
    return this.aiProvider.analyzeInterview(transcript);
  }
}
