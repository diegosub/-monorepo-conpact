import { Injectable, Logger, Scope } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable({ scope: Scope.TRANSIENT })
export class LoggerService extends Logger {

  constructor(private readonly configService: ConfigService) {
    super();
  }

  e(message: string, error: Error, context?: string): void{
    super.error(message, error.stack, context);
  }

  i(message: string, context?: string): void{
    super.log(message, context);
  }

  d(message: string, target: object, context?: string): void{
    super.debug({
      message,
      target
    }, context);
  }
}
