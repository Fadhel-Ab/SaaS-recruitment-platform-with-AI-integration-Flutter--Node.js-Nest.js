import { IsString, IsUUID } from 'class-validator';

export class CompleteInterviewDto {
  @IsUUID()
  sessionId: string;

  @IsString()
  transcript: string;
}
