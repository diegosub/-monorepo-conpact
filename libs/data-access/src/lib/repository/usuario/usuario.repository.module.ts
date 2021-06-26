import { Module } from '@nestjs/common';
import { TypegooseModule } from 'nestjs-typegoose';
import { UsuarioSchema } from '../../schema/usuario.schema';
import { UsuarioRepository } from './usuario.repository';

@Module({
  imports: [TypegooseModule.forFeature([UsuarioSchema])],
  providers: [UsuarioRepository],
  exports: [UsuarioRepository]
})
export class UsuarioRepositoryModule {}
