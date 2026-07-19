import { Module } from '@nestjs/common';

import { ConfigModule } from '@nestjs/config';
import { PrismaModule } from './prisma/prisma.module.js';
import { AuthModule } from './auth/auth.module.js';
import { AiModule } from './ai/ai.module.js';
import { AppController } from './app.controller.js';
import { AppService } from './app.service.js';
import { ApplicationsModule } from './applications/applications.module.js';
import { AvailabilityModule } from './availability/availability.module.js';
import { CommonModule } from './common/common.module.js';
import { InterviewsModule } from './interviews/interviews.module.js';
import { JobsModule } from './jobs/jobs.module.js';
import { SchedulingModule } from './scheduling/scheduling.module.js';
import { UsersModule } from './users/users.module.js';
import { APP_GUARD } from '@nestjs/core';
import { RolesGuard } from './auth/guards/roles.guard.js';

ConfigModule.forRoot({
  isGlobal: true,
});
@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),

    PrismaModule,
    AuthModule,
    UsersModule,
    JobsModule,
    ApplicationsModule,
    AiModule,
    InterviewsModule,
    AvailabilityModule,
    SchedulingModule,
    PrismaModule,
    CommonModule,
  ],
  controllers: [AppController],
  providers: [AppService, {
    provide: APP_GUARD,
    useClass: RolesGuard,
  },],
})
export class AppModule {}
