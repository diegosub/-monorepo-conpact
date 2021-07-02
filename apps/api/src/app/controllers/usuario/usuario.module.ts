import { UsuarioServiceModule } from '@admin/services';
import { Module } from '@nestjs/common';
import { UsuarioController } from './usuario.controller';


@Module({
  imports: [
    UsuarioServiceModule
  ],
  controllers: [
    UsuarioController
  ]
})
export class UsuarioModule { }
