import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { GoogleGenAI } from '@google/genai';
import { buildResumePrompt } from './prompts/resume-analysis.prompt.js';
import { ResumeAnalysis } from './interfaces/resume-analysis.interface.js';
import { buildInterviewPrompt } from './prompts/interview-analysis.prompt.js';
import { InterviewAnalysis } from './interfaces/interview-analysis.interface.js';

@Injectable()
export class AIProviderService {
  private readonly client: GoogleGenAI;

  constructor(private config: ConfigService) {
    this.client = new GoogleGenAI({
      apiKey: this.config.get<string>('GEMINI_API_KEY'),
    });
  }

  async analyzeResume(
    resume: string,
    jobDescription: string,
  ): Promise<ResumeAnalysis> {
    const prompt = buildResumePrompt(resume, jobDescription);

    const response = await this.client.models.generateContent({
      model: this.config.get<string>('GEMINI_MODEL', 'gemini-3.5-flash'),
      contents: prompt,
      config: {
        responseMimeType: 'application/json',
      },
    });

    const content = response.text;

    if (!content) {
      throw new Error('AI returned empty response');
    }

    return JSON.parse(content);
  }

  async analyzeInterview(transcript: string): Promise<InterviewAnalysis> {
    const prompt = buildInterviewPrompt(transcript);

    const response = await this.client.models.generateContent({
      model: this.config.get<string>('GEMINI_MODEL', 'gemini-3.5-flash'),

      contents: prompt,

      config: {
        responseMimeType: 'application/json',
      },
    });

    const content = response.text;

    if (!content) {
      throw new Error('AI returned empty response');
    }

    return JSON.parse(content);
  }
}
