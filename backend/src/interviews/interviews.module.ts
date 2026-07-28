import { Module } from '@nestjs/common';
import { InterviewsController } from './interviews.controller.js';
import { InterviewsService } from './interviews.service.js';
import { TwilioService } from '../twilio/twilio.service.js';

@Module({
  controllers: [InterviewsController],
  providers: [InterviewsService, TwilioService],
})
export class InterviewsModule {}
