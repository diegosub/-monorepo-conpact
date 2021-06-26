import { AuthModule } from './app/controllers/auth/auth.module';
import { FiltersModule, InterceptorsModule, LoggerServiceModule, MongodbModule } from '@admin/core';
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { CategoriaModule } from './app/controllers/categoria';
import { UsuarioModule } from './app/controllers/usuario';


@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    LoggerServiceModule,
    FiltersModule,
    InterceptorsModule,
    MongodbModule,
    CategoriaModule,
    UsuarioModule,
    AuthModule,
  ],
})
export class AppModule {}
