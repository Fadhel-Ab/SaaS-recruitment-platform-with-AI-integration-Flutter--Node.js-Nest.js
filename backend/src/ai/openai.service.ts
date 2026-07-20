import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import OpenAI from 'openai';
import { buildResumePrompt } from './prompts/resume-analysis.prompt.js';
import { ResumeAnalysis } from './interfaces/resume-analysis.interface.js';

@Injectable()
export class OpenAIService {
  private readonly client: OpenAI;

  constructor(
    private config: ConfigService,
  ) {
    this.client = new OpenAI({
      apiKey: config.get<string>('OPENAI_API_KEY'),
    });
  }

  async analyzeResume(
  resume: string,
  jobDescription: string,
): Promise<ResumeAnalysis> {

  const prompt = buildResumePrompt(
    resume,
    jobDescription,
  );

  const response =
    await this.client.chat.completions.create({
      model: 'gpt-4.1-mini',

      messages: [
        {
          role: 'user',
          content: prompt,
        },
      ],

      response_format: {
        type: 'json_object',
      },
    });


  const content =
    response.choices[0].message.content;


  if (!content) {
    throw new Error(
      'AI returned empty response',
    );
  }


  return JSON.parse(content);
}
}