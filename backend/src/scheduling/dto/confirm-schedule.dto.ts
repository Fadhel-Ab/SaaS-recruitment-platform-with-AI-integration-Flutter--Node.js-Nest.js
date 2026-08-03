import {
  IsArray,
  ValidateNested,
  IsString,
  IsInt,
  IsDateString,
} from 'class-validator';

import { Type } from 'class-transformer';

class ScheduledInterviewDto {
  @IsString()
  applicationId: string;

  @IsDateString()
  date: string;

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
