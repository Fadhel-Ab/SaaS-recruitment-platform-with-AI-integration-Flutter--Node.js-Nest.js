import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import twilio from 'twilio';

@Injectable()
export class TwilioService {
  private client;

  constructor(private config: ConfigService) {
    this.client = twilio(
      this.config.get<string>('TWILIO_ACCOUNT_SID')!,
      this.config.get<string>('TWILIO_AUTH_TOKEN')!,
    );
  }

  async makeCall(to: string, applicationId?: string) {
    const url = applicationId
      ? `${this.config.get<string>('TWILIO_WEBHOOK_URL')}/api/twilio/voice?applicationId=${applicationId}`
      : `${this.config.get<string>('TWILIO_WEBHOOK_URL')}/api/twilio/voice`;

    return this.client.calls.create({
      to,
      from: this.config.get<string>('TWILIO_PHONE_NUMBER')!,
      url,
    });
  }
  async makeTestCall() {
    return this.makeCall(this.config.get<string>('TWILIO_TEST_PHONE_NUMBER')!);
  }
}
