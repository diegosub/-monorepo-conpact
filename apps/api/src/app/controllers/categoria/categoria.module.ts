import { CategoriaController } from './categoria.controller';
import { Module } from '@nestjs/common';
import { CategoriaServiceModule } from '@admin/services';

@Module({
  imports: [
    CategoriaServiceModule
  ],
  controllers: [
    CategoriaController
  ]
})
export class CategoriaModule { }
