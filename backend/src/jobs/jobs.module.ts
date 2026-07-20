import { Module } from '@nestjs/common';
import { JobsService } from './jobs.service.js';
import { JobsController } from './jobs.controller.js';
import { PrismaModule } from '../prisma/prisma.module.js';
@Module({
  imports: [PrismaModule],
  controllers: [JobsController],
  providers: [JobsService],
})
export class JobsModule {}
