import {
  IsArray,
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
} from 'class-validator';
import { EmploymentType, SkillLevel } from '../../generated/prisma/enums.js';

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
}
