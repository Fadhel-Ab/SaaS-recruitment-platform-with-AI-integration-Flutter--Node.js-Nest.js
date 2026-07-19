import {
  Controller,
  Post,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { ApplicationsService } from './applications.service.js';
import { FileInterceptor } from '@nestjs/platform-express';
import { multerConfig } from 'common/multer.config.js';

@Controller('applications')
export class ApplicationsController {
  constructor(private applicationService: ApplicationsService) {}

  @Post('upload')
  @UseInterceptors(FileInterceptor('cvs', multerConfig))
  uploadCv(@UploadedFile() file: Express.Multer.File) {
    return {
      url: `/uploads/cvs/${file.filename}`,
    };
  }
}
