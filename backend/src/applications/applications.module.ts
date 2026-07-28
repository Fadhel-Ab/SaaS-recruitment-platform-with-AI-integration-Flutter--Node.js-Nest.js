import { Module } from '@nestjs/common';
import { ApplicationsController } from './applications.controller.js';
import { ApplicationsService } from './applications.service.js';
import { AiModule } from '../ai/ai.module.js';
import { TwilioService } from '../twilio/twilio.service.js';
import { AiInterviewService } from '../ai-interview/ai-interview.service.js';

@Module({
  imports: [AiModule],
  controllers: [ApplicationsController],
  providers: [ApplicationsService, TwilioService, AiInterviewService],
})
export class ApplicationsModule {}
