import { IsNotEmpty } from 'class-validator';

export class GenerateInterviewQuestionsDto {
  @IsNotEmpty()
  title: string;

  @IsNotEmpty()
  description: string;

  @IsNotEmpty()
  requirements: string;
}
