import { Controller, UseGuards, Post, Param, Body } from '@nestjs/common';
import { CurrentUser } from '../auth/decorators/current-user.decorator.js';
import { Roles } from '../auth/decorators/roles.decorator.js';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard.js';
import { RolesGuard } from '../auth/guards/roles.guard.js';
import { UserRole } from '../generated/prisma/enums.js';
import { GenerateScheduleDto } from './dto/generate-schedule.dto.js';
import { SchedulingService } from './scheduling.service.js';
import { ConfirmScheduleDto } from './dto/confirm-schedule.dto.js';

@Controller('scheduler')
@UseGuards(JwtAuthGuard, RolesGuard)
export class SchedulingController {
  constructor(private schedulingService: SchedulingService) {}

  @Post('jobs/:jobId/generate')
  @Roles(UserRole.MANAGER)
  generate(
    @CurrentUser() user,
    @Param('jobId') jobId: string,
    @Body() dto: GenerateScheduleDto,
  ) {
    return this.schedulingService.generate(user.id, jobId, dto.duration);
  }

  @Post('jobs/:jobId/confirm')
  @Roles(UserRole.MANAGER)
  confirm(@CurrentUser() user, @Body() dto: ConfirmScheduleDto) {
    return this.schedulingService.confirm(user.id, dto);
  }
}
