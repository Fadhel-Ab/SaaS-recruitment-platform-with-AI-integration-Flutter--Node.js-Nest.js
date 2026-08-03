import {
  Controller,
  Post,
  Get,
  Patch,
  Delete,
  Body,
  Param,
} from '@nestjs/common';

import { CurrentUser } from '../auth/decorators/current-user.decorator.js';
import { Roles } from '../auth/decorators/roles.decorator.js';
import { UserRole } from '../generated/prisma/enums.js';

import { AvailabilityService } from './availability.service.js';
import { CreateAvailabilityDto } from './dto/create-availability.dto.js';
import { UpdateAvailabilityDto } from './dto/update-availability.dto.js';

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

  @Patch(':id')
  @Roles(UserRole.MANAGER)
  update(
    @CurrentUser() user,
    @Param('id') id: string,
    @Body() dto: UpdateAvailabilityDto,
  ) {
    return this.availabilityService.update(user.id, id, dto);
  }

  @Delete(':id')
  @Roles(UserRole.MANAGER)
  remove(@CurrentUser() user, @Param('id') id: string) {
    return this.availabilityService.remove(user.id, id);
  }
}
