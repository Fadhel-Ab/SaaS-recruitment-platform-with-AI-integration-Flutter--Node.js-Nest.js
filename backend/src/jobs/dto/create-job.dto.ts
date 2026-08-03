import {
  IsArray,
  IsEnum,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';
import { EmploymentType, SkillLevel } from '../../generated/prisma/enums.js';

export class JobAvailabilitySlotDto {
  @IsInt()
  dayOfWeek: number;

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
