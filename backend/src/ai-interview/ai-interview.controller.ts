import { Body, Controller, Param, Post, Query, Res } from '@nestjs/common';
import type { Response as ExpressResponse } from 'express';

import { AiInterviewService } from './ai-interview.service.js';
import { CompleteInterviewDto } from './dto/complete_interview.dto.js';
import { Public } from '../auth/decorators/public.decorator.js';
import { TwilioService } from '../twilio/twilio.service.js';
import { AiService } from '../ai/ai.service.js';

@Controller('ai-interview')
export class AiInterviewController {
  constructor(
    private readonly aiInterviewService: AiInterviewService,
    private readonly twilioService: TwilioService,
    private readonly aiService: AiService,
  ) {}

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
    return this.aiInterviewService.complete(dto.sessionId, dto.transcript);
  }

  // --------------------------
  // FIRST QUESTION
  // --------------------------

  @Post('voice')
  @Public()
  async voice(
    @Query('applicationId') applicationId: string,
    @Res() res: ExpressResponse,
  ) {
    const question =
      await this.aiService.generateInterviewQuestion(applicationId);
    await this.aiInterviewService.saveQuestion(applicationId, question);

    const twiml = `
<Response>

  <Gather
    input="speech"
    action="/api/ai-interview/answer?applicationId=${applicationId}"
    method="POST"
    speechTimeout="5"
    speechModel="phone_call"
    enhanced="true"
    language="en-US">
    

    <Say voice="Polly.Joanna-Neural">
      Hello, this is your AI interview assistant.

      ${question}
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

  // --------------------------
  // EVERY OTHER QUESTION
  // --------------------------
  @Post('answer')
  @Public()
  async answer(
    @Query('applicationId') applicationId: string,
    @Body() body,
    @Res() res: ExpressResponse,
  ) {
    // Handle no speech detected
    if (!body.SpeechResult) {
      const twiml = `
<Response>

  <Gather
    input="speech"
    action="/api/ai-interview/answer?applicationId=${applicationId}"
    method="POST"
    timeout="5"
    speechTimeout="auto"
    speechModel="phone_call"
    enhanced="true"
    language="en-US">
    

    <Say voice="Polly.Joanna-Neural">
      I did not hear your answer. Please try again.
    </Say>

  </Gather>

  <Say voice="Polly.Joanna-Neural">
    I did not receive an answer. Goodbye.
  </Say>

</Response>
`;

      res.type('text/xml');
      return res.send(twiml);
    }

    // Save candidate answer
    const session = await this.aiInterviewService.saveAnswer(
      applicationId,
      body.SpeechResult,
    );

    console.log({
      applicationId,
      answer: body.SpeechResult,
    });

    // Finish interview after 5 answers
    if (session.questionCount >= 5) {
     await this.aiInterviewService.complete(
    session.id,
    session.transcript ?? '',
  );

      const twiml = `
<Response>
  <Say voice="Polly.Joanna-Neural">
    Thank you.

    Your interview has now been completed.

    Goodbye.
  </Say>
</Response>
`;

      res.type('text/xml');
      return res.send(twiml);
    }

    // Generate next AI question
    const nextQuestion =
      await this.aiService.generateInterviewQuestion(applicationId);

    await this.aiInterviewService.saveQuestion(applicationId, nextQuestion);

    const twiml = `
<Response>

  <Gather
    input="speech"
    action="/api/ai-interview/answer?applicationId=${applicationId}"
    method="POST"
    timeout="5"
    speechTimeout="auto"
    speechModel="phone_call"
    enhanced="true"
    language="en-US">
   

    <Say voice="Polly.Joanna-Neural">
      ${nextQuestion}
    </Say>

  </Gather>

  <Say voice="Polly.Joanna-Neural">
    I did not hear a response. Goodbye.
  </Say>

</Response>
`;

    res.type('text/xml');
    res.send(twiml);
  }
}
