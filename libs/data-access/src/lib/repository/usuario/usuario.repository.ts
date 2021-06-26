import { Injectable } from '@nestjs/common';
import { ReturnModelType } from '@typegoose/typegoose';
import { InjectModel } from 'nestjs-typegoose';
import { UsuarioSchema } from '../../schema/usuario.schema';
import { QueryHelper } from '../../query';
import { DataSetPage, FiltrosDTO, Usuario } from '@admin/domain';

@Injectable()
export class UsuarioRepository {

  constructor(
    @InjectModel(UsuarioSchema)
    private readonly usuarioModel: ReturnModelType<typeof UsuarioSchema>
  ) { }

  async get(id: string): Promise<Usuario> {
    return await this.usuarioModel.findOne({ _id: id }, { senha: false });
  }

  async getByEmail(email: string): Promise<Usuario> {
    return await this.usuarioModel.findOne({ email });
  }

  async pesquisar(filtros: Usuario): Promise<Usuario[]> {
    const queryHelper = new QueryHelper();

    queryHelper.like("nome", filtros?.nome);

    return await this.usuarioModel.find(queryHelper.filters);
  }

  async inserir(usuario: Usuario): Promise<Usuario> {
    const novoUsuario = new this.usuarioModel(usuario);
    const usuarioCriado = await novoUsuario.save();
    return await this.get(usuarioCriado._id);
  }

  async alterar(id: string, usuario: Usuario): Promise<Usuario> {
    await this.usuarioModel.updateOne({ _id: id }, usuario);
    return await this.get(id);
  }

  async pesquisarPaginado(filtros: FiltrosDTO): Promise<DataSetPage<Usuario>> {
    const queryHelper = new QueryHelper();

    queryHelper.like("nome", filtros.value.nome)

    const order = queryHelper.setOrder(filtros.sortActive, filtros.sortDirection);

    const total = await this.usuarioModel.countDocuments(queryHelper.filters);
    const usuarios = await this.usuarioModel.find(queryHelper.filters, [], {
      limit: filtros.pageSize,
      skip: filtros.pageNumber * filtros.pageSize,
      sort: order.sort
    });
    return new DataSetPage(usuarios, total);
  }

}
