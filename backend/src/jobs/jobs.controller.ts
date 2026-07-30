import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { CurrentUser } from '../auth/decorators/current-user.decorator.js';
import { Roles } from '../auth/decorators/roles.decorator.js';
import { UserRole } from '../generated/prisma/enums.js';
import { JobsService } from './jobs.service.js';
import { CreateJobDto } from './dto/create-job.dto.js';
import { Public } from '../auth/decorators/public.decorator.js';

@Controller('jobs')
export class JobsController {
  constructor(private jobsService: JobsService) {}

  @Get()
  @Public()
  getAvailableJobs() {
    return this.jobsService.getAvailableJobs();
  }

  @Post()
  @Roles(UserRole.MANAGER)
  create(@CurrentUser() user, @Body() dto: CreateJobDto) {
    console.log('CURRENT USER:', user);
    return this.jobsService.create(user.id, dto);
  }

  @Get('my')
  @Roles(UserRole.MANAGER)
  findMine(@CurrentUser() user) {
    return this.jobsService.findMine(user.id);
  }

  @Get(':id/applications')
  @Roles(UserRole.MANAGER)
  getApplications(@Param('id') jobId: string) {
    return this.jobsService.getApplications(jobId);
  }

  @Get(':token')
  @Public()
  findByToken(@Param('token') token: string) {
    return this.jobsService.findByToken(token);
  }
}
