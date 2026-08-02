import { Module } from '@nestjs/common';
import { JobsService } from './jobs.service.js';
import { JobsController } from './jobs.controller.js';
import { PrismaModule } from '../prisma/prisma.module.js';
import { AiModule } from '../ai/ai.module.js';
@Module({
  imports: [PrismaModule, AiModule],
  controllers: [JobsController],
  providers: [JobsService],
})
export class JobsModule {}
