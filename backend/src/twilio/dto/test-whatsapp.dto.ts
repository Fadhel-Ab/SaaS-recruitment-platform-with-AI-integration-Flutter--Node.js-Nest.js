import { IsInt, IsOptional, IsString, Matches, Max, Min } from 'class-validator';

export class TestWhatsAppDto {
  @Matches(/^\+[1-9]\d{6,14}$/, {
    message: 'phone must be in E.164 format, e.g. +15551234567',
  })
  phone: string;

  @IsOptional()
  @IsString()
  message?: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(3600)
  delaySeconds?: number;
}
