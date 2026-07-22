import { Body, Controller, Post } from '@nestjs/common';
import { AiInterviewService } from './ai-interview.service.js';
import { StartInterviewDto } from './dto/start_interview.dto.js';

@Controller('ai-interview')
export class AiInterviewController {
  constructor(private readonly aiInterviewService: AiInterviewService) {}

  @Post('start')
  start(@Body() dto: StartInterviewDto) {
    return this.aiInterviewService.start(dto);
  }
}
