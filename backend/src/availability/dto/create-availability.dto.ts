import {
  IsDateString,
  IsIn,
  IsInt,
  IsNotEmpty,
  Max,
  Min,
  ValidateIf,
} from 'class-validator';
import { AvailabilityRecurrence } from '../../generated/prisma/enums.js';

export class CreateAvailabilityDto {
  @IsIn([AvailabilityRecurrence.RECURRING, AvailabilityRecurrence.SPECIFIC])
  recurrence: AvailabilityRecurrence;

  @ValidateIf((dto) => dto.recurrence === AvailabilityRecurrence.SPECIFIC)
  @IsDateString()
  date?: string;

  @ValidateIf((dto) => dto.recurrence === AvailabilityRecurrence.RECURRING)
  @IsInt()
  @Min(1)
  @Max(7)
  dayOfWeek?: number;

  @IsNotEmpty()
  startTime: string;

  @IsNotEmpty()
  endTime: string;
}
