import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import type { Request, Response } from 'express';
import { Prisma } from '../../generated/prisma/client.js';

interface ErrorBody {
  statusCode: number;
  message: string | string[];
  error: string;
}

@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  private readonly logger = new Logger('ExceptionsFilter');

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    const { status, body } = this.resolve(exception);

    if (status >= 500) {
      this.logger.error(
        `${request.method} ${request.url} -> ${status}`,
        exception instanceof Error ? exception.stack : String(exception),
      );
    } else {
      this.logger.warn(`${request.method} ${request.url} -> ${status}`);
    }

    response.status(status).json({
      ...body,
      path: request.url,
      timestamp: new Date().toISOString(),
    });
  }

  private resolve(exception: unknown): { status: number; body: ErrorBody } {
    if (exception instanceof HttpException) {
      const status = exception.getStatus();
      const payload = exception.getResponse();

      if (typeof payload === 'string') {
        return {
          status,
          body: { statusCode: status, message: payload, error: exception.name },
        };
      }

      const { message, error } = payload as {
        message?: string | string[];
        error?: string;
      };

      return {
        status,
        body: {
          statusCode: status,
          message: message ?? exception.message,
          error: error ?? exception.name,
        },
      };
    }

    if (exception instanceof Prisma.PrismaClientKnownRequestError) {
      return this.resolvePrismaError(exception);
    }

    return {
      status: HttpStatus.INTERNAL_SERVER_ERROR,
      body: {
        statusCode: HttpStatus.INTERNAL_SERVER_ERROR,
        message: 'Something went wrong. Please try again shortly.',
        error: 'Internal Server Error',
      },
    };
  }

  private resolvePrismaError(
    exception: Prisma.PrismaClientKnownRequestError,
  ): { status: number; body: ErrorBody } {
    switch (exception.code) {
      case 'P2002':
        return {
          status: HttpStatus.CONFLICT,
          body: {
            statusCode: HttpStatus.CONFLICT,
            message: 'A record with these details already exists.',
            error: 'Conflict',
          },
        };
      case 'P2025':
        return {
          status: HttpStatus.NOT_FOUND,
          body: {
            statusCode: HttpStatus.NOT_FOUND,
            message: 'The requested record could not be found.',
            error: 'Not Found',
          },
        };
      default:
        return {
          status: HttpStatus.INTERNAL_SERVER_ERROR,
          body: {
            statusCode: HttpStatus.INTERNAL_SERVER_ERROR,
            message: 'Something went wrong. Please try again shortly.',
            error: 'Internal Server Error',
          },
        };
    }
  }
}
