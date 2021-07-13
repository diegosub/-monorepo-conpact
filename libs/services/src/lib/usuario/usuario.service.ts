
import { QueryHelper, Usuario } from '@admin/domain';
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Connection, Repository } from 'typeorm';

@Injectable()
export class UsuarioService {

  public static SITUACAO_ATIVA: number = 1;

  constructor(
    @InjectRepository(Usuario)
    private readonly repository: Repository<Usuario>,
    private connection: Connection
  ) { }

  async getById(codigo: number): Promise<Usuario> {
    return await this.repository.findOne(codigo);
  }

  async get(filtros: Usuario): Promise<Usuario> {

    const queryHelper = new QueryHelper();

    queryHelper.numberEqual("codigo", filtros.codigo);
    queryHelper.textLike("nome", filtros.nome);
    queryHelper.textLike("login", filtros.login);
    queryHelper.rawEqual("situacao", filtros.situacao);

    return await this.repository.findOne(queryHelper.filters);

  }

  async getByLogin(login: string): Promise<Usuario> {
    return await this.repository.findOne({login: login});
  }

  // async pesquisar(filtros: Usuario): Promise<Usuario[]> {
  //   return await this.usuarioRepository.pesquisar(filtros);
  // }

  // async ativarUsuario(email: string): Promise<Usuario> {
  //   const usuario = await this.getByEmail(email);
  //   if (!usuario) {
  //     throw new NotFoundException('Usuário não encontrado');
  //   }
  //   usuario.ativo = true;
  //   usuario.dataAtivacao = DateUtils.now();
  //   return await this.usuarioRepository.alterar(usuario._id, usuario);
  // }

  // async authUser(email: string): Promise<Usuario> {
  //   return await this.repository.getByEmail(email);
  // }

  // async inserir(usuario: Usuario): Promise<Usuario> {
  //   return await this.repository.inserir(usuario);
  // }

  async inserir(usuario: Usuario): Promise<Usuario> {
    const queryRunner = this.connection.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      const retorno = await queryRunner.manager.save(usuario);
      await queryRunner.commitTransaction();
      return retorno;
    } catch (err) {
      await queryRunner.rollbackTransaction();
      throw new Error(err);
    } finally {
      await queryRunner.release();
    }

  }

  // async alterar(id: string, usuario: Usuario): Promise<Usuario> {
  //  return await this.usuarioRepository.alterar(id, usuario);
  // }

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
