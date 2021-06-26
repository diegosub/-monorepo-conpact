
import { Module } from '@nestjs/common';
import { TypegooseModule } from 'nestjs-typegoose';
import { CategoriaSchema } from '../../schema/categoria.schema';
import { CategoriaRepository } from './categoria.repository';

@Module({
  imports: [TypegooseModule.forFeature([CategoriaSchema])],
  providers: [CategoriaRepository],
  exports: [CategoriaRepository]
})
export class CategoriaRepositoryModule {}
