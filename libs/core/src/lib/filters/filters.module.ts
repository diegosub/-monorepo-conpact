
import { Module } from '@nestjs/common';
import { LoggerServiceModule } from '../logger';
import { ExceptionsFilter } from './exception';


@Module({
  imports: [
    LoggerServiceModule
  ],
  providers: [
    ExceptionsFilter
  ],
  exports: [
    ExceptionsFilter
  ]
})
export class FiltersModule { }
