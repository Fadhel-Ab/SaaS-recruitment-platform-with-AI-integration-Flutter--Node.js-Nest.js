import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { CurrentUser } from '../auth/decorators/current-user.decorator.js';
import { Roles } from '../auth/decorators/roles.decorator.js';
import { UserRole } from '../generated/prisma/enums.js';
import type { CurrentUserData } from '../auth/interfaces/current-user.interface.js';
import { CreateInterviewDto } from './dto/create-interview.dto.js';
import { InterviewsService } from './interviews.service.js';

@Controller('interviews')
export class InterviewsController {
  constructor(private readonly interviewsService: InterviewsService) {}

  @Get('today')
  @Roles(UserRole.MANAGER)
  getToday(@CurrentUser() user: CurrentUserData) {
    return this.interviewsService.getToday(user.id);
  }

  @Post(':applicationId')
  @Roles(UserRole.MANAGER)
  create(
    @CurrentUser() user,
    @Param('applicationId') applicationId: string,
    @Body() dto: CreateInterviewDto,
  ) {
    return this.interviewsService.create(user.id, applicationId, dto);
  }
}
