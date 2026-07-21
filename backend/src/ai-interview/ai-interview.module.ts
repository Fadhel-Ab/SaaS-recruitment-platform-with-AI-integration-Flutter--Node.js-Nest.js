import { Module } from '@nestjs/common';
import { AiInterviewController } from './ai-interview.controller';
import { AiInterviewService } from './ai-interview.service';

@Module({
  controllers: [AiInterviewController],
  providers: [AiInterviewService]
})
export class AiInterviewModule {}
