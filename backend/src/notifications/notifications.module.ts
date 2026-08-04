import { Module } from '@nestjs/common';
import { NotificationsService } from './notifications.service.js';
import { TwilioModule } from '../twilio/twilio.module.js';

@Module({
  imports: [TwilioModule],
  providers: [NotificationsService],
})
export class NotificationsModule {}
