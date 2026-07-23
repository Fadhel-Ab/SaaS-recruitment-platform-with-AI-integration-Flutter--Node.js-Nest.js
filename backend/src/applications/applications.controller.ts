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

@Controller('applications')
export class ApplicationsController {
  constructor(private readonly applicationsService: ApplicationsService) {}

  @Get('job/:jobId')
  getJobApplications(@Param('jobId') jobId: string) {
    return this.applicationsService.getJobApplications(jobId);
  }

  @Get(':applicationId')
  getApplicationDetails(
    @Param('applicationId')
    applicationId: string,
  ) {
    return this.applicationsService.getApplicationDetails(applicationId);
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
  updateStatus(
    @Param('applicationId')
    applicationId: string,

    @Body()
    dto: UpdateApplicationStatusDto,
  ) {
    return this.applicationsService.updateStatus(applicationId, dto);
  }
}
