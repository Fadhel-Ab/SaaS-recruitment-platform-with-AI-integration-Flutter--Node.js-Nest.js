import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TwilioService } from './twilio.service.js';
import { TwilioController } from './twilio.controller.js';

@Module({
  imports: [ConfigModule],
  controllers: [TwilioController],
  providers: [TwilioService],
  exports: [TwilioService],
})
export class TwilioModule {}