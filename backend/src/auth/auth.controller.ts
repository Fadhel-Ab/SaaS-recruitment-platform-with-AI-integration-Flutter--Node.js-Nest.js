import { Body, Controller, Get, Post, Req } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import { AuthService } from './auth.service.js';
import { LoginDto } from './dto/login.dto.js';
import { RegisterDto } from './dto/register.dto.js';
import { JwtAuthGuard } from './guards/jwt-auth.guard.js';
import { Public } from './decorators/public.decorator.js';
import { CurrentUser } from './decorators/current-user.decorator.js';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}
  @Get('me')
  getMe(@CurrentUser() user) {
    return user;
  }
  @Get('profile')
  profile(@Req() req) {
    return req.user;
  }
  @Post('register')
  @Public()
  @Throttle({ default: { limit: 5, ttl: 60000 } })
  register(@Body() dto: RegisterDto) {
    return this.authService.register(dto);
  }

  @Post('login')
  @Public()
  @Throttle({ default: { limit: 5, ttl: 60000 } })
  login(@Body() dto: LoginDto) {
    return this.authService.login(dto);
  }
}
