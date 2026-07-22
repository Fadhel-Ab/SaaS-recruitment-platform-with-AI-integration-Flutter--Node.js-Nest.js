import { Module } from '@nestjs/common';
import { AiInterviewController } from './ai-interview.controller.js';
import { AiInterviewService } from './ai-interview.service.js';

@Module({
  controllers: [AiInterviewController],
  providers: [AiInterviewService]
})
export class AiInterviewModule {}
