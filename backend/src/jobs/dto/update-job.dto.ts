import { IsEnum, IsNotEmpty, IsOptional } from 'class-validator';
import {
  EmploymentType,
  JobStatus,
  SkillLevel,
} from '../../generated/prisma/enums.js';

export class UpdateJobDto {
  @IsOptional()
  @IsNotEmpty()
  title?: string;

  @IsOptional()
  @IsNotEmpty()
  description?: string;

  @IsOptional()
  @IsNotEmpty()
  requirements?: string;

  @IsOptional()
  @IsEnum(EmploymentType)
  employmentType?: EmploymentType;

  @IsOptional()
  @IsNotEmpty()
  companyName?: string;

  @IsOptional()
  @IsNotEmpty()
  location?: string;

  @IsOptional()
  @IsEnum(SkillLevel)
  skillLevel?: SkillLevel;

  @IsOptional()
  @IsEnum(JobStatus)
  status?: JobStatus;
}
