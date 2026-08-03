import { IsArray, IsEnum, IsString } from 'class-validator';
import { ApplicationStatus } from '../../generated/prisma/enums.js';

export class BulkUpdateStatusDto {
  @IsArray()
  @IsString({ each: true })
  applicationIds: string[];

  @IsEnum(ApplicationStatus)
  status: ApplicationStatus;
}
