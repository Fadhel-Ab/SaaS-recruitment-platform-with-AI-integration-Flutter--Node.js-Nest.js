import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { CurrentUser } from '../auth/decorators/current-user.decorator.js';
import { Roles } from '../auth/decorators/roles.decorator.js';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard.js';
import { UserRole } from '../generated/prisma/enums.js';
import { JobsService } from './jobs.service.js';
import { CreateJobDto } from './dto/create-job.dto.js';

@Controller('jobs')
export class JobsController {
  constructor(private jobsService: JobsService) {}

  @Post()
  @Roles(UserRole.MANAGER)
  create(@CurrentUser() user, @Body() dto: CreateJobDto) {
    return this.jobsService.create(user.id, dto);
  }

  @Get('my')
  @Roles(UserRole.MANAGER)
  findMine(@CurrentUser() user) {
    return this.jobsService.findMine(user.id);
  }

  @Get(':token')
  findByToken(@Param('token') token: string) {
    return this.jobsService.findByToken(token);
  }
  @Get(':id/applications')
  @Roles(UserRole.MANAGER)
  getApplications(@Param('id') jobId: string) {
    return this.jobsService.getApplications(jobId);
  }
}
