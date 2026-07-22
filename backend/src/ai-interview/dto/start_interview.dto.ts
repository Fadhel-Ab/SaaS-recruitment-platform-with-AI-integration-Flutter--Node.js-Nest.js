import { IsUUID } from 'class-validator';

export class StartInterviewDto {
  @IsUUID()
  applicationId: string;
}
