import { Body, Controller, Param, Post, Query, Res } from '@nestjs/common';
import { TwilioService } from './twilio.service.js';
import { ConfigService } from '@nestjs/config';
import { Public } from '../auth/decorators/public.decorator.js';
import type { Response as ExpressResponse } from 'express';
import { Roles } from '../auth/decorators/roles.decorator.js';
import { UserRole } from '../generated/prisma/enums.js';
import { InterviewsService } from '../interviews/interviews.service.js';
import { AiInterviewService } from '../ai-interview/ai-interview.service.js';
@Controller('twilio')
export class TwilioController {
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

  console.log('CALL STATUS:', status);

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
}
