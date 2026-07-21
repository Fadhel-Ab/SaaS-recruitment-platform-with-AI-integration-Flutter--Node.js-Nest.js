import { IsArray, ValidateNested, IsString, IsInt } from 'class-validator';

import { Type } from 'class-transformer';

class ScheduledInterviewDto {
  @IsString()
  applicationId: string;

  @IsInt()
  dayOfWeek: number;

  @IsString()
  time: string;
}

export class ConfirmScheduleDto {
  @IsInt()
  duration: number;
  
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => ScheduledInterviewDto)
  interviews: ScheduledInterviewDto[];
}
