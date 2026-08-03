import { IsInt, IsOptional } from 'class-validator';

export class UpdateAvailabilityDto {
  @IsOptional()
  @IsInt()
  dayOfWeek?: number;

  @IsOptional()
  startTime?: string;

  @IsOptional()
  endTime?: string;
}
