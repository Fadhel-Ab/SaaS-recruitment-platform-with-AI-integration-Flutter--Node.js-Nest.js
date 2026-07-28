import { Controller, Param, Post, Res } from '@nestjs/common';
import { TwilioService } from './twilio.service.js';
import { ConfigService } from '@nestjs/config';
import { Public } from '../auth/decorators/public.decorator.js';
import type { Response as ExpressResponse } from 'express';
import { Roles } from '../auth/decorators/roles.decorator.js';
import { UserRole } from '../generated/prisma/enums.js';
import { InterviewsService } from '../interviews/interviews.service.js';
@Controller('twilio')
export class TwilioController {
  constructor(
    private readonly twilio: TwilioService,
    private readonly interviewsService: InterviewsService,
  ) {}

  @Post('test-call')
  @Public()
  async testCall() {
    return this.twilio.makeTestCall();
  }
  @Post(':id/start-call')
  @Roles(UserRole.MANAGER)
  startCall(@Param('id') applicationId: string) {
    return this.interviewsService.startAiCall(applicationId);
  }

  @Post('voice')
  @Public()
  voice(@Res() res: ExpressResponse) {
    const twiml = `
    <Response>
      <Say voice="alice">
        Hello, this is your AI interview assistant.
        We will begin your interview shortly.
      </Say>
    </Response>
  `;

    res.type('text/xml');
    res.send(twiml);
  }
}
