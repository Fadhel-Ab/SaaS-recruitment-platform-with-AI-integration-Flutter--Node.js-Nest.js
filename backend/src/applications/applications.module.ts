import { Module } from '@nestjs/common';
import { ApplicationsController } from './applications.controller.js';
import { ApplicationsService } from './applications.service.js';
import { AiModule } from '../ai/ai.module.js';
import { TwilioService } from '../twilio/twilio.service.js';
import { AiInterviewService } from '../ai-interview/ai-interview.service.js';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';

@Module({
  imports: [
    AiModule,
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        secret: config.get<string>('JWT_SECRET'),
      }),
    }),
  ],
  controllers: [ApplicationsController],
  providers: [ApplicationsService, TwilioService, AiInterviewService],
})
export class ApplicationsModule {}
