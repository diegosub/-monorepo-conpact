import { LoggerService } from '@admin/core';
import { AgrupadorModule } from './app/controllers/agrupador/agrupador.module';
import { AuthModule } from './app/controllers/auth/auth.module';
import { FiltersModule, InterceptorsModule, LoggerServiceModule, TypeormModule } from '@admin/core';
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { UsuarioModule } from './app/controllers/usuario/usuario.module';
import { TypeOrmModule } from '@nestjs/typeorm';
import { getConnectionOptions } from 'typeorm';


@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    TypeOrmModule.forRootAsync({
      useFactory: async () =>
        Object.assign(await getConnectionOptions(), {
          autoLoadEntities: true,
          //logger: new LoggerService()
        }),
    }),
    LoggerServiceModule,
    FiltersModule,
    InterceptorsModule,
    UsuarioModule,
    AgrupadorModule,
    AuthModule,
  ],
})
export class AppModule {}
