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
  constructor(private readonly twilio: TwilioService) {}

  
}
