import {
  BadRequestException,
  Body,
  Controller,
  Headers,
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
import { multerConfig, generateResumeFileName } from '../common/multer.config.js';
import { UpdateApplicationStatusDto } from './dto/update-application-status.dto.js';
import { BulkUpdateStatusDto } from './dto/bulk-update-status.dto.js';
import { UserRole } from '../generated/prisma/enums.js';
import { CurrentUser } from '../auth/decorators/current-user.decorator.js';
import type { CurrentUserData } from '../auth/interfaces/current-user.interface.js';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard.js';
import { RolesGuard } from '../auth/guards/roles.guard.js';
import { Public } from '../auth/decorators/public.decorator.js';
import { JwtService } from '@nestjs/jwt';
import { StorageService } from '../common/storage/storage.service.js';

@Controller('applications')
export class ApplicationsController {
  constructor(
    private readonly applicationsService: ApplicationsService,
    private readonly jwtService: JwtService,
    private readonly storageService: StorageService,
  ) {}

  @Get('job/:jobId')
  @Roles(UserRole.MANAGER)
  getJobApplications(
    @Param('jobId') jobId: string,
    @CurrentUser() user: CurrentUserData,
  ) {
    return this.applicationsService.getJobApplications(user.id, jobId);
  }

  @Get('mine')
  @Roles(UserRole.CANDIDATE)
  getMyApplications(@CurrentUser() user: CurrentUserData) {
    return this.applicationsService.getMyApplications(user.id, user.email);
  }

  @Get('mine/profile')
  @Roles(UserRole.CANDIDATE)
  getMyProfile(@CurrentUser() user: CurrentUserData) {
    return this.applicationsService.getMyProfile(user.id, user.email);
  }

  @Get('pipeline')
  @Roles(UserRole.MANAGER)
  getPipeline(@CurrentUser() user: CurrentUserData) {
    return this.applicationsService.getPipeline(user.id);
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
  @Public()
  @UseInterceptors(FileInterceptor('cvs', multerConfig))
  async uploadCv(@UploadedFile() file: Express.Multer.File) {
    if (!file) {
      throw new BadRequestException(
        'No file uploaded, or the file is not a PDF/DOC/DOCX.',
      );
    }

    const fileName = generateResumeFileName(file.originalname);
    await this.storageService.uploadResume(fileName, file.buffer, file.mimetype);

    return { fileName };
  }

  @Post(':shareToken')
  @Public()
  apply(
    @Param('shareToken') shareToken: string,
    @Body() dto: CreateApplicationDto,
    @Headers('authorization') authorization?: string,
  ) {
    const currentUser = this.getOptionalCurrentUser(authorization);

    return this.applicationsService.apply(shareToken, dto, currentUser);
  }

  private getOptionalCurrentUser(
    authorization?: string,
  ): CurrentUserData | undefined {
    const [type, token] = authorization?.split(' ') ?? [];

    if (type !== 'Bearer' || !token) {
      return undefined;
    }

    try {
      const payload = this.jwtService.verify(token);

      return {
        id: payload.sub,
        email: payload.email,
        role: payload.role,
      };
    } catch {
      return undefined;
    }
  }

  @Patch(':applicationId/status')
  @Roles(UserRole.MANAGER)
  updateStatus(
    @Param('applicationId') applicationId: string,
    @CurrentUser() user: CurrentUserData,
    @Body()
    dto: UpdateApplicationStatusDto,
  ) {
    return this.applicationsService.updateStatus(user.id, applicationId, dto);
  }

  @Patch('bulk-status')
  @Roles(UserRole.MANAGER)
  bulkUpdateStatus(
    @CurrentUser() user: CurrentUserData,
    @Body() dto: BulkUpdateStatusDto,
  ) {
    return this.applicationsService.bulkUpdateStatus(
      user.id,
      dto.applicationIds,
      dto.status,
    );
  }
}
