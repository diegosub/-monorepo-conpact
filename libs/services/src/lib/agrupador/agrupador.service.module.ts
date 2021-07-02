import { Agrupador } from '@admin/domain';
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AgrupadorService } from './agrupador.service';

@Module({
  imports: [TypeOrmModule.forFeature([Agrupador])],
  providers: [AgrupadorService],
  exports: [AgrupadorService]
})
export class AgrupadorServiceModule {}
