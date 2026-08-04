import { Logger, ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import { join } from 'path';
import * as express from 'express';
import helmet from 'helmet';
import { AppModule } from './app.module.js';

async function bootstrap() {
  const logger = new Logger('Bootstrap');
  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  app.use(
    helmet({
      // The frontend (a separate origin) loads uploaded resumes/images
      // directly, so relax the default same-origin resource policy.
      crossOriginResourcePolicy: { policy: 'cross-origin' },
    }),
  );

  app.setGlobalPrefix('api');

  // Twilio sends application/x-www-form-urlencoded
  app.use(express.urlencoded({ extended: true }));

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
    }),
  );

  app.useStaticAssets(join(process.cwd(), 'uploads'), {
    prefix: '/uploads',
  });

  app.enableCors();

  const port = process.env.PORT ?? 3000;
  await app.listen(port);
  logger.log(`Listening on port ${port}`);
}

bootstrap();
