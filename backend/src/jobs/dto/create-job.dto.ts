import {
  IsArray,
  IsDateString,
  IsEnum,
  IsIn,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  Max,
  Min,
  ValidateIf,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';
import {
  AvailabilityRecurrence,
  EmploymentType,
  SkillLevel,
} from '../../generated/prisma/enums.js';

export class JobAvailabilitySlotDto {
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

export class CreateJobDto {
  @IsNotEmpty()
  title: string;

  @IsNotEmpty()
  description: string;

  @IsNotEmpty()
  requirements: string;

  @IsNotEmpty()
  employmentType: EmploymentType;

  @IsNotEmpty()
  companyName: string;

  @IsNotEmpty()
  location: string;

  @IsEnum(SkillLevel)
  skillLevel: SkillLevel;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  interviewQuestions?: string[];

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => JobAvailabilitySlotDto)
  availability?: JobAvailabilitySlotDto[];
}
