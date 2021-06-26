
import { UsuarioController } from './usuario.controller';
import { Module } from '@nestjs/common';
import { UsuarioServiceModule } from '@admin/services';

@Module({
  imports: [
    UsuarioServiceModule
  ],
  controllers: [
    UsuarioController
  ]
})
export class UsuarioModule { }
