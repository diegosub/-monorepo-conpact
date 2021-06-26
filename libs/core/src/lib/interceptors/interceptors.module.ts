
import { Module } from '@nestjs/common';
import { LoggerServiceModule } from '../logger';
import { LoggingInterceptor } from './logging.interceptor';


@Module({
  imports: [
    LoggerServiceModule
  ],
  providers: [
    LoggingInterceptor
  ],
  exports: [
    LoggingInterceptor
  ]
})
export class InterceptorsModule { }
