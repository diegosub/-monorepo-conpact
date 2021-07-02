import { AgrupadorServiceModule } from '@admin/services';
import { Module } from '@nestjs/common';
import { AgrupadorController } from './agrupador.controller';


@Module({
  imports: [
    AgrupadorServiceModule
  ],
  controllers: [
    AgrupadorController
  ]
})
export class AgrupadorModule { }
