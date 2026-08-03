import {
  IsDateString,
  IsIn,
  IsInt,
  IsOptional,
  Max,
  Min,
  ValidateIf,
} from 'class-validator';
import { AvailabilityRecurrence } from '../../generated/prisma/enums.js';

export class UpdateAvailabilityDto {
  @IsOptional()
  @IsIn([AvailabilityRecurrence.RECURRING, AvailabilityRecurrence.SPECIFIC])
  recurrence?: AvailabilityRecurrence;

  @ValidateIf((dto) => dto.recurrence === AvailabilityRecurrence.SPECIFIC)
  @IsDateString()
  date?: string;

  @ValidateIf((dto) => dto.recurrence === AvailabilityRecurrence.RECURRING)
  @IsInt()
  @Min(1)
  @Max(7)
  dayOfWeek?: number;

  @IsOptional()
  startTime?: string;

  @IsOptional()
  endTime?: string;
}
