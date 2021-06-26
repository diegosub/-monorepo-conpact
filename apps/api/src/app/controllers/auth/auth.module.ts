
import { AuthServiceModule, UsuarioServiceModule } from '@admin/services';
import { Module } from '@nestjs/common';
import { AuthController } from './auth.controller';

@Module({
    imports: [
      AuthServiceModule,
      UsuarioServiceModule
    ],
    controllers: [
      AuthController
    ]
})
export class AuthModule { }
