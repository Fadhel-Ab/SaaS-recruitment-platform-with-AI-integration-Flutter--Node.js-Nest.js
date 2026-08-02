import { forwardRef, Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TwilioService } from './twilio.service.js';
import { TwilioController } from './twilio.controller.js';
import { AiInterviewModule } from '../ai-interview/ai-interview.module.js';

@Module({
  imports: [ConfigModule, ConfigModule, forwardRef(() => AiInterviewModule)],
  controllers: [TwilioController],
  providers: [TwilioService], 
  exports: [TwilioService],
})
export class TwilioModule {}
