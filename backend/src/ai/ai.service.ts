import { Injectable, Logger } from '@nestjs/common';
import { AIProviderService } from './ai.provider.service.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { ResumeParserService } from './resume-parser.service.js';
import { StorageService } from '../common/storage/storage.service.js';

@Injectable()
export class AiService {
  private readonly logger = new Logger(AiService.name);

  constructor(
    private prisma: PrismaService,
    private parser: ResumeParserService,
    private aiProvider: AIProviderService,
    private storage: StorageService,
  ) {}

  async processApplication(applicationId: string) {
    this.logger.log(`Processing AI resume analysis for application ${applicationId}`);

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

    this.logger.debug(`Extracted ${resumeText.length} chars from resume`);

    const analysis = await this.aiProvider.analyzeResume(
      resumeText,
      application.job.description,
    );

    this.logger.debug(`AI resume score for ${applicationId}: ${analysis.score}`);

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

    this.logger.log(`AI score saved for application ${applicationId}`);

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

  async generateInterviewQuestions(
    title: string,
    description: string,
    requirements: string,
    count = 5,
  ): Promise<string[]> {
    const jobDescription = `${title}\n\n${description}\n\nRequirements:\n${requirements}`;

    return this.aiProvider.generateInterviewQuestionSet(jobDescription, count);
  }
}
