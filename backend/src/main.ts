import { Logger, ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import * as express from 'express';
import type { RequestHandler } from 'express';
import * as helmetModule from 'helmet';
import { AppModule } from './app.module.js';

// Helmet ships separate ESM and CommonJS type definitions. Vercel's TypeScript
// build resolves the CommonJS ones, where a default import is the whole module
// object instead of the helmet() function ("This expression is not callable").
// Unwrapping `.default` until we reach the function works in every module mode.
function resolveHelmet(
  mod: unknown,
): (options?: helmetModule.HelmetOptions) => RequestHandler {
  let current: any = mod;
  while (typeof current !== 'function' && current?.default) {
    current = current.default;
  }
  return current;
}
const helmet = resolveHelmet(helmetModule);

async function bootstrap() {
  const logger = new Logger('Bootstrap');
  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  app.use(helmet());

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

  app.enableCors();

  const port = process.env.PORT ?? 3000;
  await app.listen(port);
  logger.log(`Listening on port ${port}`);
}

bootstrap();
