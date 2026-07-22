import { Module } from '@nestjs/common';
import { AiInterviewController } from './ai-interview.controller.js';
import { AiInterviewService } from './ai-interview.service.js';
import { AiModule } from '../ai/ai.module.js';

@Module({
  imports: [AiModule],
  controllers: [AiInterviewController],
  providers: [AiInterviewService],
})
export class AiInterviewModule {}
