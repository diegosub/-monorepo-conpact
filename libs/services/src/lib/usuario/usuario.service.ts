import { UsuarioRepository } from '@admin/data-access';
import { DataSetPage, DateUtils, FiltrosDTO, Usuario } from '@admin/domain';
import { Injectable, NotFoundException } from '@nestjs/common';

@Injectable()
export class UsuarioService {
  constructor(
    private readonly usuarioRepository: UsuarioRepository,
  ) { }

  async get(id: string): Promise<Usuario> {
    return await this.usuarioRepository.get(id);
  }

  async getByEmail(id: string): Promise<Usuario> {
    return await this.usuarioRepository.getByEmail(id);
  }

  async pesquisar(filtros: Usuario): Promise<Usuario[]> {
    return await this.usuarioRepository.pesquisar(filtros);
  }

  async ativarUsuario(email: string): Promise<Usuario> {
    const usuario = await this.getByEmail(email);
    if (!usuario) {
      throw new NotFoundException('Usuário não encontrado');
    }
    usuario.ativo = true;
    usuario.dataAtivacao = DateUtils.now();
    return await this.usuarioRepository.alterar(usuario._id, usuario);
  }

  async authUser(email: string): Promise<Usuario> {
    return await this.usuarioRepository.getByEmail(email);
  }

  async inserir(usuario: Usuario): Promise<Usuario> {
    return await this.usuarioRepository.inserir(usuario);
  }

  async alterar(id: string, usuario: Usuario): Promise<Usuario> {
   return await this.usuarioRepository.alterar(id, usuario);
  }

  async listarUsuariosPaginado(filtros: FiltrosDTO): Promise<DataSetPage<Usuario>> {
    return await this.usuarioRepository.pesquisarPaginado(filtros);
  }

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
