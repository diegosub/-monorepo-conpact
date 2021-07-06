import { Injectable, Logger, Scope } from '@nestjs/common';
import { QueryRunner } from 'typeorm';
import sqlFormatter from '@sqltools/formatter';

@Injectable({ scope: Scope.TRANSIENT })
export class LoggerService extends Logger {

  constructor() {
    super();
  }

  logQueryError(query: string, parameters?: any[], queryRunner?: QueryRunner) {
    const requestUrl = queryRunner && queryRunner.data["request"] ? "(" + queryRunner.data["request"].url + ") " : "";
    console.log(requestUrl + "SQL Executado: " + sqlFormatter.format(query));
  }

  e(message: string, error: Error, context?: string): void {
    super.error(message, error.stack, context);
  }

  i(message: string, context?: string): void {
    super.log(message, context);
  }

  d(message: string, target: object, context?: string): void {
    super.debug({
      message,
      target
    }, context);
  }
}
