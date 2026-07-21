import { IsInt } from 'class-validator';

export class GenerateScheduleDto {
  @IsInt()
  duration: number = 30;
}
