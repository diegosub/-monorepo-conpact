import { CategoriaRepository } from '@admin/data-access';
import { DataSetPage, Categoria, FiltrosDTO } from '@admin/domain';
import { Injectable } from '@nestjs/common';

@Injectable()
export class CategoriaService {

  constructor(
    private readonly categoriaRepository: CategoriaRepository
  ) { }

  async get(id: string): Promise<Categoria> {
    return await this.categoriaRepository.get(id);
  }

  async pesquisar(filtros: Categoria): Promise<Categoria[]> {
    return await this.categoriaRepository.pesquisar(filtros);
  }

  async inserir(categoria: Categoria): Promise<Categoria> {
    return await this.categoriaRepository.inserir(categoria);
  }

  async alterar(id: string, categoria: Categoria): Promise<Categoria> {
    return await this.categoriaRepository.alterar(id, categoria);
  }

  async pesquisarPaginado(filtros: FiltrosDTO): Promise<DataSetPage<Categoria>> {
    return await this.categoriaRepository.pesquisarPaginado(filtros);
  }


}
