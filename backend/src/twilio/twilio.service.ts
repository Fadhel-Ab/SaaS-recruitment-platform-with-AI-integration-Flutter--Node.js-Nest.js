import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import twilio from 'twilio';

@Injectable()
export class TwilioService {
  private readonly logger = new Logger(TwilioService.name);
  private client;

  constructor(private config: ConfigService) {
    this.client = twilio(
      this.config.get<string>('TWILIO_ACCOUNT_SID')!,
      this.config.get<string>('TWILIO_AUTH_TOKEN')!,
    );
  }

  private getWhatsAppSender() {
    return (
      this.config.get<string>('TWILIO_WHATSAPP_FROM') ?? 'whatsapp:+14155238886'
    );
  }

  async makeCall(to: string, applicationId?: string) {
    const url = applicationId
      ? `${this.config.get<string>('TWILIO_WEBHOOK_URL')}/api/ai-interview/voice?applicationId=${applicationId}`
      : `${this.config.get<string>('TWILIO_WEBHOOK_URL')}/api/ai-interview/voice`;

    this.logger.log(`Creating call for application ${applicationId ?? 'test'}`);

    const call = await this.client.calls.create({
      to,
      from: this.config.get<string>('TWILIO_PHONE_NUMBER')!,
      url,

      statusCallback: `${this.config.get<string>('TWILIO_WEBHOOK_URL')}/api/twilio/call-status?applicationId=${applicationId}`,
      statusCallbackEvent: ['completed'],

      statusCallbackMethod: 'POST',
    });

    this.logger.debug(`Twilio call ${call.sid} status: ${call.status}`);

    return call;
  }

  async makeTestCall(applicationId?: string) {
    return this.makeCall(
      this.config.get<string>('TWILIO_TEST_PHONE_NUMBER')!,
      applicationId,
    );
  }

  async sendWhatsApp(phone: string, message: string) {
    return this.client.messages.create({
      from: this.getWhatsAppSender(),

      to: `whatsapp:${phone}`,

      body: message,
    });
  }

  async sendMissedCallMessage(phone: string, jobTitle: string) {
    return this.client.messages.create({
      from: this.getWhatsAppSender(),

      to: `whatsapp:${phone}`,

      body:
        `You missed your AI interview for "${jobTitle}".\n\n` +
        `Reply with CALL to receive another interview call.`,
    });
  }
}
