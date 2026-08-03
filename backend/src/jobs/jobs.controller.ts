import { Body, Controller, Get, Param, Patch, Post } from '@nestjs/common';
import { CurrentUser } from '../auth/decorators/current-user.decorator.js';
import { Roles } from '../auth/decorators/roles.decorator.js';
import { UserRole } from '../generated/prisma/enums.js';
import { JobsService } from './jobs.service.js';
import { CreateJobDto } from './dto/create-job.dto.js';
import { UpdateJobDto } from './dto/update-job.dto.js';
import { GenerateInterviewQuestionsDto } from './dto/generate-interview-questions.dto.js';
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

  @Post('generate-interview-questions')
  @Roles(UserRole.MANAGER)
  generateInterviewQuestions(@Body() dto: GenerateInterviewQuestionsDto) {
    return this.jobsService.generateInterviewQuestions(dto);
  }

  @Get('my')
  @Roles(UserRole.MANAGER)
  findMine(@CurrentUser() user) {
    return this.jobsService.findMine(user.id);
  }

  @Get('default-availability')
  @Roles(UserRole.MANAGER)
  getDefaultAvailability(@CurrentUser() user) {
    return this.jobsService.getDefaultAvailability(user.id);
  }

  @Patch(':id')
  @Roles(UserRole.MANAGER)
  update(
    @CurrentUser() user,
    @Param('id') id: string,
    @Body() dto: UpdateJobDto,
  ) {
    return this.jobsService.update(user.id, id, dto);
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
