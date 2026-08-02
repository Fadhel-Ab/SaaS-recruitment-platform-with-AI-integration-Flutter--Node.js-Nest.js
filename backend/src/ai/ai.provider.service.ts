import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { GoogleGenAI } from '@google/genai';
import { buildResumePrompt } from './prompts/resume-analysis.prompt.js';
import { ResumeAnalysis } from './interfaces/resume-analysis.interface.js';
import {
  buildInterviewPrompt,
  buildInterviewQuestionPrompt,
  buildInterviewQuestionSetPrompt,
} from './prompts/interview-analysis.prompt.js';
import { InterviewAnalysis } from './interfaces/interview-analysis.interface.js';

@Injectable()
export class AIProviderService implements OnModuleInit {
  private readonly client: GoogleGenAI;
  private readonly logger = new Logger(AIProviderService.name);

  // Hardcoded to Lite as the standard operational lane to avoid the 20 RPD cap entirely
  private readonly fallbackModel = 'gemini-3.5-flash-lite';
  private readonly primaryModel: string;

  constructor(private config: ConfigService) {
    this.client = new GoogleGenAI({
      apiKey: this.config.get<string>('GEMINI_API_KEY'),
    });
    // Fallback to flash-lite directly if no specific model override is found in env
    this.primaryModel = this.config.get<string>(
      'GEMINI_MODEL',
      'gemini-3.5-flash-lite',
    );
  }

  async onModuleInit(): Promise<void> {
    this.logger.log(
      `AI Engine ready. Running with stable fallback model config: [${this.primaryModel}]`,
    );
  }

  /**
   * Safe execution wrapper that runs queries on the baseline engine.
   * If any quota issue hits, it uses an isolated fallback block to keep Twilio alive.
   */
  private async executePrompt(
    prompt: string,
    configOptions: Record<string, any> = {},
  ): Promise<string> {
    try {
      const response = await this.client.models.generateContent({
        model: this.primaryModel,
        contents: prompt,
        config: configOptions,
      });
      return (response.text ?? '').slice();
    } catch (error: any) {
      const errorMessage = error?.message || '';

      this.logger.error(
        `Execution failure on target model [${this.primaryModel}]: ${errorMessage}`,
      );

      // Emergency Check: If your primary model target breaks or runs out of daily quota,
      // explicitly route it to the high-throughput fallback model instance.
      if (this.primaryModel !== this.fallbackModel) {
        this.logger.warn(
          `Bypassing broken model context. Forcing traffic lane to: ${this.fallbackModel}`,
        );
        try {
          const fallbackResponse = await this.client.models.generateContent({
            model: this.fallbackModel,
            contents: prompt,
            config: configOptions,
          });
          return (fallbackResponse.text ?? '').slice();
        } catch (fallbackError: any) {
          this.logger.error(
            `Critical: Both API model tracks exhausted: ${fallbackError.message}`,
          );
          throw fallbackError;
        }
      }

      throw error;
    }
  }

  async analyzeResume(
    resume: string,
    jobDescription: string,
  ): Promise<ResumeAnalysis> {
    const prompt = buildResumePrompt(resume, jobDescription);
    const content = await this.executePrompt(prompt, {
      responseMimeType: 'application/json',
    });

    if (!content) {
      throw new Error('AI returned empty response');
    }
    return JSON.parse(content);
  }

  async analyzeInterview(transcript: string): Promise<InterviewAnalysis> {
    const prompt = buildInterviewPrompt(transcript);
    const content = await this.executePrompt(prompt, {
      responseMimeType: 'application/json',
    });

    if (!content) {
      throw new Error('AI returned empty response');
    }
    return JSON.parse(content);
  }

  async generateInterviewQuestion(
    jobDescription: string,
    transcript: string,
  ): Promise<string> {
    const prompt = buildInterviewQuestionPrompt(jobDescription, transcript);
    return await this.executePrompt(prompt);
  }

  async generateInterviewQuestionSet(
    jobDescription: string,
    count = 5,
  ): Promise<string[]> {
    const prompt = buildInterviewQuestionSetPrompt(jobDescription, count);
    const content = await this.executePrompt(prompt, {
      responseMimeType: 'application/json',
    });

    if (!content) {
      throw new Error('AI returned empty response');
    }

    return JSON.parse(content);
  }
}
