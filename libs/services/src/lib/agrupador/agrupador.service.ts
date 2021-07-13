import { Agrupador, NegocioException, QueryHelper } from '@admin/domain';
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Connection, QueryRunner, Repository } from 'typeorm';
import { GenericService } from './../generic/generic.service';

@Injectable()
export class AgrupadorService extends GenericService<Agrupador> {
  constructor(
    @InjectRepository(Agrupador)
    protected readonly repository: Repository<Agrupador>,
    protected connection: Connection
  ) {
    super(repository, connection);
  }

  async pesquisar(filtros: Agrupador): Promise<Agrupador[]> {

    const queryHelper = new QueryHelper();

    queryHelper.numberEqual("codigo", filtros.codigo);
    queryHelper.textLike("descricao", filtros.descricao);
    queryHelper.rawEqual("ativo", filtros.ativo);

    const order = queryHelper.setOrder("descricao", "asc");

    return await this.repository.find({
        where: queryHelper.filters,
        order: queryHelper.sort
    });
  }

  async validarInserir(queryRunner: QueryRunner, agrupador: Agrupador) {
    const queryHelper = new QueryHelper();
    queryHelper.textLike("descricao", agrupador.descricao);
    queryHelper.numberEqual("codigoCadastroUnico", agrupador.codigoCadastroUnico);
    let count = await this.repository.count(queryHelper.filters);

    if(count > 0) {
      throw new NegocioException("Já existe uma categoria cadastrada com essa descrição.");
    }
  }

  inativarEntidade(agrupador: Agrupador) {
    agrupador.ativo = false;
    agrupador.dataAlteracao = new Date()
  }

  ativarEntidade(agrupador: Agrupador) {
    agrupador.ativo = true;
    agrupador.dataAlteracao = new Date()
  }


  // async listarUsuariosPaginado(filtros: FiltrosDTO): Promise<DataSetPage<Usuario>> {
  //   return await this.usuarioRepository.pesquisarPaginado(filtros);
  // }

}
