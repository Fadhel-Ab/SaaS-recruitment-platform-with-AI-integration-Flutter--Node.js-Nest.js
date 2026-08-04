import {
  Body,
  Controller,
  Logger,
  Param,
  Post,
  Query,
  Res,
} from '@nestjs/common';
import { SkipThrottle } from '@nestjs/throttler';
import { TwilioService } from './twilio.service.js';
import { ConfigService } from '@nestjs/config';
import { Public } from '../auth/decorators/public.decorator.js';
import type { Response as ExpressResponse } from 'express';
import { Roles } from '../auth/decorators/roles.decorator.js';
import { UserRole } from '../generated/prisma/enums.js';
import { InterviewsService } from '../interviews/interviews.service.js';
import { AiInterviewService } from '../ai-interview/ai-interview.service.js';
import { TestWhatsAppDto } from './dto/test-whatsapp.dto.js';
@Controller('twilio')
@SkipThrottle()
export class TwilioController {
  private readonly logger = new Logger(TwilioController.name);

  constructor(
    private readonly twilio: TwilioService,
    private readonly aiInterviewService: AiInterviewService,
  ) {}

  @Public()
  @Post('whatsapp')
  async incomingWhatsApp(@Body() body: any) {
    const message = (body.Body ?? '').trim().toUpperCase();

    if (message !== 'CALL') {
      return;
    }

    const phone = (body.From as string)?.replace('whatsapp:', '');

    const application =
      await this.aiInterviewService.findLatestApplicationByPhone(phone);

    if (!application) {
      return;
    }

    await this.aiInterviewService.startAiCall(application.id);
  }
@Public()
@Post('call-status')
async callStatus(
  @Body() body: any,
  @Query('applicationId') applicationId: string,
) {
  const status = body.CallStatus;

  this.logger.log(`Call status for application ${applicationId}: ${status}`);

  if (
    status === 'no-answer' ||
    status === 'busy' ||
    status === 'failed'
  ) {

    const application =
      await this.aiInterviewService.getApplication(applicationId);

    if (!application) {
      return;
    }

    if (application.candidate.phone) {
      await this.twilio.sendMissedCallMessage(
        application.candidate.phone,
        application.job.title,
      );
    }
  }
}

  @Roles(UserRole.MANAGER)
  @Post('test-whatsapp')
  testWhatsApp(@Body() dto: TestWhatsAppDto) {
    const delayMs = (dto.delaySeconds ?? 0) * 1000;
    const message =
      dto.message ??
      'This is a test WhatsApp message from the recruitment platform.';

    setTimeout(() => {
      this.twilio.sendWhatsApp(dto.phone, message).catch((error) => {
        this.logger.error(
          `Test WhatsApp send failed for ${dto.phone}`,
          error instanceof Error ? error.stack : error,
        );
      });
    }, delayMs);

    this.logger.log(
      `Test WhatsApp to ${dto.phone} scheduled in ${dto.delaySeconds ?? 0}s`,
    );

    return {
      scheduled: true,
      phone: dto.phone,
      willSendAt: new Date(Date.now() + delayMs).toISOString(),
    };
  }
}
