import { IsEnum, IsNotEmpty } from 'class-validator';
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

  @IsEnum(SkillLevel)
  skillLevel: SkillLevel;
}
