import { IsInt, IsNotEmpty } from 'class-validator';

export class CreateAvailabilityDto {
  @IsNotEmpty()
  @IsInt()
  dayOfWeek: number;

  @IsNotEmpty()
  startTime: string;

  @IsNotEmpty()
  endTime: string;
}
