import { Agrupador, AgrupadorAlterarDto, AgrupadorInserirDto, QueryHelper } from '@admin/domain';
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Connection, Repository } from 'typeorm';

@Injectable()
export class AgrupadorService {
  constructor(
    @InjectRepository(Agrupador)
    private readonly repository: Repository<Agrupador>,
    private connection: Connection
  ) { }

  async getById(codigo: number): Promise<Agrupador> {
    return await this.repository.findOne(codigo);
  }

  async pesquisar(filtros: Agrupador): Promise<Agrupador[]> {

    const queryHelper = new QueryHelper();

    queryHelper.idEqual("codigo", filtros.codigo);
    queryHelper.like("descricao", filtros.descricao);
    queryHelper.rawEqual("ativo", filtros.ativo);

    return await this.repository.find(queryHelper.filters);
  }

  async inserir(agrupadorDto: AgrupadorInserirDto): Promise<Agrupador> {
    const queryRunner = this.connection.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      const agrupador = this.repository.create(agrupadorDto);
      const retorno = await queryRunner.manager.save(agrupador);
      await queryRunner.commitTransaction();
      return retorno;
    } catch (err) {
      await queryRunner.rollbackTransaction();
      throw new Error(err);
    } finally {
      await queryRunner.release();
    }

  }

  async alterar(codigo: number, agrupadorDto: AgrupadorAlterarDto): Promise<Agrupador> {
    const queryRunner = this.connection.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      const agrupador = this.repository.create(agrupadorDto);
      const retorno = await queryRunner.manager.save(agrupador);
      await queryRunner.commitTransaction();
      return retorno;
    } catch (err) {
      await queryRunner.rollbackTransaction();
      throw new Error(err);
    } finally {
      await queryRunner.release();
    }

  }

  // async listarUsuariosPaginado(filtros: FiltrosDTO): Promise<DataSetPage<Usuario>> {
  //   return await this.usuarioRepository.pesquisarPaginado(filtros);
  // }

  // async alterarSenha(id: string, alterarSenha: AlterarSenhaDTO): Promise<Usuario> {
  //   const usuario = await this.usuarioRepository.obterUsuarioPorIdComSenha(id);

  //   if (!usuario) {
  //     throw new NotFoundException('Usuário não encontrado');
  //   }

  //   if (!this.securityService.validarSenha(alterarSenha.senhaAtual, usuario.senha)) {
  //     throw new BadRequestException('Senha Atual não confere');
  //   }

  //   if (alterarSenha.novaSenha !== alterarSenha.confirmSenha) {
  //     throw new BadRequestException('Confirmar Nova Senha não confere');
  //   }

  //   if (this.securityService.validarSenha(alterarSenha.novaSenha, usuario.senha)) {
  //     throw new BadRequestException('A Nova Senha tem que ser diferente da Senha Atual');
  //   }

  //   const usuarioDto = new Usuario();
  //   usuarioDto.senha = this.securityService.cryptSenha(alterarSenha.novaSenha);
  //   return await this.usuarioRepository.atualizarUsuario(id, usuarioDto);
  //  }
}
