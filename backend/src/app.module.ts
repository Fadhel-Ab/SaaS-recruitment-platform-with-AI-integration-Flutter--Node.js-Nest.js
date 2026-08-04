import { Module } from '@nestjs/common';
import { APP_FILTER } from '@nestjs/core';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';
import { ScheduleModule } from '@nestjs/schedule';

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
import { StorageModule } from './common/storage/storage.module.js';
import { JwtAuthGuard } from './auth/guards/jwt-auth.guard.js';
import { AiInterviewModule } from './ai-interview/ai-interview.module.js';
import { DashboardModule } from './dashboard/dashboard.module.js';
import { TwilioModule } from './twilio/twilio.module.js';
import { SearchModule } from './search/search.module.js';
import { AllExceptionsFilter } from './common/filters/all-exceptions.filter.js';
import { NotificationsModule } from './notifications/notifications.module.js';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    ScheduleModule.forRoot(),
    ThrottlerModule.forRoot([
      {
        name: 'default',
        ttl: 60000,
        limit: 100,
      },
    ]),
    StorageModule,
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
    AiInterviewModule,
    DashboardModule,
    TwilioModule,
    SearchModule,
    NotificationsModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
    {
      provide: APP_GUARD,
      useClass: JwtAuthGuard,
    },
    {
      provide: APP_GUARD,
      useClass: RolesGuard,
    },
    {
      provide: APP_FILTER,
      useClass: AllExceptionsFilter,
    },
  ],
})
export class AppModule {}
