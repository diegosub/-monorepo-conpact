import { CategoriaRepositoryModule } from '@admin/data-access';
import { Module } from '@nestjs/common';
import { CategoriaService } from './categoria.service';

@Module({
  imports: [
    CategoriaRepositoryModule
  ],
  providers: [CategoriaService],
  exports: [CategoriaService]
})
export class CategoriaServiceModule {}
