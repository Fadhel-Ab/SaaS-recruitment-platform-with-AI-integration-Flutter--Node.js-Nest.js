import { forwardRef, Module } from '@nestjs/common';
import { AiInterviewController } from './ai-interview.controller.js';
import { AiInterviewService } from './ai-interview.service.js';
import { AiModule } from '../ai/ai.module.js';
import { TwilioModule } from '../twilio/twilio.module.js';

@Module({
  imports: [AiModule, forwardRef(() => TwilioModule)],
  controllers: [AiInterviewController],
  providers: [AiInterviewService],
  exports: [AiInterviewService],
})
export class AiInterviewModule {}
