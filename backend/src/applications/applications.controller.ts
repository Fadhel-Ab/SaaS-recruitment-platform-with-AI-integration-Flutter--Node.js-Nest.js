import {
  Body,
  Controller,
  Param,
  Post,
  UploadedFile,
  UseInterceptors,
  Patch,
  Get,
} from '@nestjs/common';
import { Roles } from '../auth/decorators/roles.decorator.js';
import { FileInterceptor } from '@nestjs/platform-express';

import { ApplicationsService } from './applications.service.js';
import { CreateApplicationDto } from './dto/create-application.dto.js';
import { multerConfig } from '../common/multer.config.js';
import { UpdateApplicationStatusDto } from './dto/update-application-status.dto.js';
import { UserRole } from '../generated/prisma/enums.js';
import { CurrentUser } from '../auth/decorators/current-user.decorator.js';
import type { CurrentUserData } from '../auth/interfaces/current-user.interface.js';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard.js';
import { RolesGuard } from '../auth/guards/roles.guard.js';

@Controller('applications')
export class ApplicationsController {
  constructor(private readonly applicationsService: ApplicationsService) {}

  @Get('job/:jobId')
  @Roles(UserRole.MANAGER)
  getJobApplications(
    @Param('jobId') jobId: string,
    @CurrentUser() user: CurrentUserData,
  ) {
    return this.applicationsService.getJobApplications(user.id, jobId);
  }

  @Get(':applicationId')
  @Roles(UserRole.MANAGER)
  getApplicationDetails(
    @Param('applicationId') applicationId: string,
    @CurrentUser() user: CurrentUserData,
  ) {
    return this.applicationsService.getApplicationDetails(
      user.id,
      applicationId,
    );
  }

  @Post('upload')
  @UseInterceptors(FileInterceptor('cvs', multerConfig))
  uploadCv(@UploadedFile() file: Express.Multer.File) {
    return {
      fileName: file.filename,
    };
  }

  @Post(':shareToken')
  apply(
    @Param('shareToken') shareToken: string,
    @Body() dto: CreateApplicationDto,
  ) {
    return this.applicationsService.apply(shareToken, dto);
  }

  @Patch(':applicationId/status')
  @Roles(UserRole.MANAGER)
  updateStatus(
    @Param('applicationId') applicationId: string,
    @CurrentUser() user: CurrentUserData,
    @Body()
    dto: UpdateApplicationStatusDto,
  ) {
    return this.applicationsService.updateStatus(user.id,applicationId, dto);
  }
}
