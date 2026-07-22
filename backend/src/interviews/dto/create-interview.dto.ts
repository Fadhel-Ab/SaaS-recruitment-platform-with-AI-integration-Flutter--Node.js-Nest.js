import { IsDateString, IsOptional, IsInt, IsUUID } from 'class-validator';

export class CreateInterviewDto {
  @IsDateString()
  @IsOptional()
  scheduledAt?: string;

  @IsInt()
  @IsOptional()
  duration?: number;

  @IsOptional()
  meetingLink?: string;
}
