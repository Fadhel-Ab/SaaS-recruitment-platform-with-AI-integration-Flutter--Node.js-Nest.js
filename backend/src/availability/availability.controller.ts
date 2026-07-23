import { Body, Controller, Get, Post } from '@nestjs/common';
import { Roles } from '../auth/decorators/roles.decorator.js';
import { UserRole } from '../generated/prisma/enums.js';
import { CurrentUser } from '../auth/decorators/current-user.decorator.js';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard.js';
import { RolesGuard } from '../auth/guards/roles.guard.js';
import { AvailabilityService } from './availability.service.js';
import { CreateAvailabilityDto } from './dto/create-availability.dto.js';

@Controller('availability')
export class AvailabilityController {
  constructor(private service: AvailabilityService) {}

  @Post()
  @Roles(UserRole.MANAGER)
  create(@CurrentUser() user, @Body() dto: CreateAvailabilityDto) {
    return this.service.create(user.id, dto);
  }

  @Get()
  @Roles(UserRole.MANAGER)
  findMine(@CurrentUser() user) {
    return this.service.findMine(user.id);
  }
}
