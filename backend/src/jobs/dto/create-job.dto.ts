import { IsNotEmpty } from 'class-validator';
import { EmploymentType } from '../../generated/prisma/enums.js';

export class CreateJobDto {
  @IsNotEmpty()
  title: string;

  @IsNotEmpty()
  description: string;

  @IsNotEmpty()
  requirements: string;

  @IsNotEmpty()
  employmentType: EmploymentType;
}
