import { IsOptional, Matches } from 'class-validator';

export class UpdateProfileDto {
  @IsOptional()
  @Matches(/^\+[1-9]\d{6,14}$/, {
    message: 'phone must be in E.164 format, e.g. +15551234567',
  })
  phone?: string;
}
