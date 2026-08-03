import { Controller, Get, Query } from '@nestjs/common';
import { CurrentUser } from '../auth/decorators/current-user.decorator.js';
import { Roles } from '../auth/decorators/roles.decorator.js';
import { UserRole } from '../generated/prisma/enums.js';
import type { CurrentUserData } from '../auth/interfaces/current-user.interface.js';
import { SearchService } from './search.service.js';

@Controller('search')
export class SearchController {
  constructor(private searchService: SearchService) {}

  @Get()
  @Roles(UserRole.MANAGER)
  search(@Query('q') q: string, @CurrentUser() user: CurrentUserData) {
    return this.searchService.search(user.id, q ?? '');
  }
}
