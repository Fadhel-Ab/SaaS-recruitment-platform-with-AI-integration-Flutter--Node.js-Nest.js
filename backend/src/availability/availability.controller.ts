import { Controller, Post, Get, Body } from '@nestjs/common';

import { CurrentUser } from '../auth/decorators/current-user.decorator.js';
import { Roles } from '../auth/decorators/roles.decorator.js';
import { UserRole } from '../generated/prisma/enums.js';

import { AvailabilityService } from './availability.service.js';
import { CreateAvailabilityDto } from './dto/create-availability.dto.js';

@Controller('availability')
export class AvailabilityController {
  constructor(private availabilityService: AvailabilityService) {}

  @Post()
  @Roles(UserRole.MANAGER)
  create(@CurrentUser() user, @Body() dto: CreateAvailabilityDto) {
    return this.availabilityService.save(user.id, dto);
  }

  @Get('my')
  @Roles(UserRole.MANAGER)
  findMine(@CurrentUser() user) {
    return this.availabilityService.findMine(user.id);
  }
}
