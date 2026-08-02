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
    console.log('AI PROCESS START:', applicationId);

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

    const resumeText = await this.parser.extractText(filePath);

    console.log('RESUME EXTRACTED LENGTH:', resumeText.length);

    const analysis = await this.aiProvider.analyzeResume(
      resumeText,
      application.job.description,
    );

    console.log('AI ANALYSIS:', analysis);

    console.log('CREATING AI SCORE:', analysis.score);

    await this.prisma.aIScore.upsert({
      where: {
        applicationId: application.id,
      },

      update: {
        cvScore: analysis.score,
        overallScore: analysis.score,
        strengths: analysis.strengths,
        weaknesses: analysis.weaknesses,
        summary: analysis.summary,
        recommendation: analysis.recommendation,
      },

      create: {
        applicationId: application.id,
        cvScore: analysis.score,
        overallScore: analysis.score,
        strengths: analysis.strengths,
        weaknesses: analysis.weaknesses,
        summary: analysis.summary,
        recommendation: analysis.recommendation,
      },
    });

    console.log('AI SCORE SAVED SUCCESSFULLY');

    return analysis;
  }

  async evaluateInterview(transcript: string) {
    return this.aiProvider.analyzeInterview(transcript);
  }

  async generateInterviewQuestion(applicationId: string) {
    const application = await this.prisma.application.findUnique({
      where: {
        id: applicationId,
      },
      include: {
        job: true,
        aiInterview: true,
      },
    });

    if (!application) {
      throw new Error('Application not found');
    }

    return this.aiProvider.generateInterviewQuestion(
      application.job.description,
      application.aiInterview?.transcript ?? '',
    );
  }
}
