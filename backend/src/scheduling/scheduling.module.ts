import { Module } from '@nestjs/common';
import { SchedulingService } from './scheduling.service.js';
import { SchedulingController } from './scheduling.controller.js';
import { TwilioModule } from '../twilio/twilio.module.js';

@Module({
  imports: [TwilioModule],
  controllers: [SchedulingController],
  providers: [SchedulingService],
})
export class SchedulingModule {}
