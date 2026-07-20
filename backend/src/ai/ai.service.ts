import { Injectable } from '@nestjs/common';
import { OpenAIService } from './openai.service.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { ResumeParserService } from './resume-parser.service.js';
import { join } from 'path';
import { StorageService } from '../common/storage/storage.service.js';

@Injectable()
export class AiService {
  constructor(
    private prisma: PrismaService,
    private parser: ResumeParserService,
    private openAI: OpenAIService,
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
    const filePath = this.storage.getResumePath(
      application!.candidate.resumeFileName!,
    );

    const resumeText = await this.parser.extractText(filePath);

    const analysis = await this.openAI.analyzeResume(
      resumeText,
      application!.job.description,
    );

    await this.prisma.aIScore.create({
      data: {
        applicationId: application!.id,

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
}
