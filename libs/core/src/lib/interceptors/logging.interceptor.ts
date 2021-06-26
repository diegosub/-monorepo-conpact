import {
  CallHandler, ExecutionContext, Injectable,
  NestInterceptor
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';
import { LoggerService } from '../logger';

@Injectable()
export class LoggingInterceptor implements NestInterceptor {

  constructor(private readonly loggerService: LoggerService){
  }

  intercept(
    context: ExecutionContext,
    call: CallHandler<any>
  ): Observable<any> {
    const request = context.switchToHttp().getRequest();
    const requestLog = {
      hostname: request.hostname,
      url: request.url,
      requestMethod: request.method,
      requestBody: request.body,
      requestHeaders: request.headers,
      processTime: ''
    };

    const now = Date.now();
    return call.handle().pipe(
      tap(() => {
        requestLog.processTime = `${Date.now() - now}ms`;
        this.loggerService.log(requestLog);
      })
    );
  }
}
