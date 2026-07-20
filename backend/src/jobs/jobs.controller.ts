import { Controller, Get, Param, UseGuards } from '@nestjs/common';
import { CurrentUser } from '../auth/decorators/current-user.decorator.js';
import { Roles } from '../auth/decorators/roles.decorator.js';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard.js';
import { UserRole } from '../generated/prisma/enums.js';
import { JobsService } from './jobs.service.js';

@Controller('jobs')
export class JobsController {
  constructor(private jobsService: JobsService) {}

  @Get('my')
  @UseGuards(JwtAuthGuard)
  @Roles(UserRole.MANAGER)
  findMine(@CurrentUser() user) {
    return this.jobsService.findMine(user.id);
  }

  @Get(':token')
  findByToken(@Param('token') token: string) {
    return this.jobsService.findByToken(token);
  }
}
