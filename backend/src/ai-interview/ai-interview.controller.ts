import { Body, Controller, Param, Post, Query, Res } from '@nestjs/common';
import { AiInterviewService } from './ai-interview.service.js';
import { StartInterviewDto } from './dto/start_interview.dto.js';
import { CompleteInterviewDto } from './dto/complete_interview.dto.js';
import { Public } from '../auth/decorators/public.decorator.js';
import type { Response as ExpressResponse } from 'express';
import { TwilioService } from '../twilio/twilio.service.js';
import { UserRole } from '../generated/prisma/enums.js';
import { Roles } from '../auth/decorators/roles.decorator.js';
@Controller('ai-interview')
export class AiInterviewController {
  constructor(
    private readonly aiInterviewService: AiInterviewService,
    private twilioService: TwilioService,
  ) {}

  @Post('start')
  start(@Body() dto: StartInterviewDto) {
    return this.aiInterviewService.start(dto);
  }
  @Post('test-call')
  @Public()
  async testCall() {
    return this.twilioService.makeTestCall();
  }

  @Post(':id/start-call')
  @Public()
  startCall(@Param('id') applicationId: string) {
    return this.aiInterviewService.startAiCall(applicationId);
  }
  @Post('complete')
  complete(@Body() dto: CompleteInterviewDto) {
    return this.aiInterviewService.complete(dto);
  }

  @Post('voice')
  @Public()
  voice(
    @Query('applicationId') applicationId: string,
    @Res() res: ExpressResponse,
  ) {
    const twiml = `
    <Response>
      <Gather 
        input="speech"
        action="/api/ai-interview/answer?applicationId=${applicationId}"
        method="POST"
        speechTimeout="auto">

        <Say voice="Polly.Joanna-Neural">
          Hello, this is your AI interview assistant.
          Can you tell me about yourself.
        </Say>

      </Gather>

      <Say>
        I did not hear a response. Goodbye.
      </Say>

    </Response>
  `;

    res.type('text/xml');
    res.send(twiml);
  }

  @Post('answer')
  @Public()
  async saveAnswer(
    @Query('applicationId') applicationId: string,
    @Body() body,
    @Res() res: ExpressResponse,
  ) {
    await this.aiInterviewService.saveAnswer(applicationId, body.SpeechResult);

    console.log({
      applicationId,
      answer: body.SpeechResult,
    });

    const twiml = `
<Response>

<Gather
 input="speech"
 action="/api/ai-interview/answer?applicationId=${applicationId}"
 method="POST"
 speechTimeout="auto">

<Say voice="Polly.Joanna-Neural">
Thank you.
Can you tell me about your previous projects?
</Say>

</Gather>

</Response>
`;

    res.type('text/xml');
    res.send(twiml);
  }
}
