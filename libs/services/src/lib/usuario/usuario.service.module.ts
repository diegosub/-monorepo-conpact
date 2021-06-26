
import { UsuarioRepositoryModule } from '@admin/data-access';
import { Module } from '@nestjs/common';
import { UsuarioService } from './usuario.service';

@Module({
  imports: [
    UsuarioRepositoryModule
  ],
  providers: [UsuarioService],
  exports: [UsuarioService]
})
export class UsuarioServiceModule {}
