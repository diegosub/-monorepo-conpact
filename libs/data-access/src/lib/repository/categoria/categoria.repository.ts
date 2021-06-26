import { Injectable } from '@nestjs/common';
import { ReturnModelType } from '@typegoose/typegoose';
import { InjectModel } from 'nestjs-typegoose';
import { QueryHelper } from '../../query/query.helper';
import { Categoria, DataSetPage, FiltrosDTO } from '@admin/domain';
import { CategoriaSchema } from '../../schema/categoria.schema';

@Injectable()
export class CategoriaRepository {

  constructor(
    @InjectModel(CategoriaSchema)
    private readonly categoriaModel: ReturnModelType<typeof CategoriaSchema>
  ) { }

  async get(id: string): Promise<Categoria> {
    return await this.categoriaModel.findOne({ _id: id });
  }

  async pesquisar(filtros: Categoria): Promise<Categoria[]> {
    const queryHelper = new QueryHelper();

    queryHelper.idEqual("_id", filtros?._id);
    queryHelper.like("descricao", filtros?.descricao);
    queryHelper.rawEqual("ativo", filtros?.ativo);

    return await this.categoriaModel.find(queryHelper.filters);
  }

  async inserir(categoria: Categoria): Promise<Categoria> {
    const novaCategoria = new this.categoriaModel(categoria);
    const categoriaCriada = await novaCategoria.save();
    return await this.get(categoriaCriada._id);
  }

  async alterar(id: string, categoria: Categoria): Promise<Categoria> {
    await this.categoriaModel.updateOne({ _id: id }, categoria);
    return await this.get(id);
  }

  async pesquisarPaginado(filtros: FiltrosDTO): Promise<DataSetPage<Categoria>> {
    const queryHelper = new QueryHelper();

    queryHelper.like("descricao", filtros.value.descricao);

    const order = queryHelper.setOrder(filtros.sortActive, filtros.sortDirection);

    const total = await this.categoriaModel.countDocuments(queryHelper.filters);
    const categorias = await this.categoriaModel.find(queryHelper.filters, [], {
      limit: filtros.pageSize,
      skip: filtros.pageNumber * filtros.pageSize,
      sort: order.sort
    });
    return new DataSetPage(categorias, total);
  }
}
