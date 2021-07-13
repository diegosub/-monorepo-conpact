import { Usuario } from '@admin/domain';
import { BadRequestException, Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { SecurityService } from '../security/security.service';
import { UsuarioService } from '../usuario/usuario.service';


@Injectable()
export class AuthService {

  constructor(
    private readonly configService: ConfigService,
    private readonly jwtService: JwtService,
    private readonly usuarioService: UsuarioService,
    private readonly securityService: SecurityService,
  ) { }

  async validateUser(username: string) {
    let usuario = new Usuario();
    usuario.login = username;
    usuario.situacao = UsuarioService.SITUACAO_ATIVA;

    const retorno = await this.usuarioService.get(usuario);

    if(retorno) {
      return {
        codigo: retorno.codigo,
        login: retorno.login,
        nome: retorno.nome,
        codigoCadastroUnico: retorno.codigoCadastroUnico
      }
    } else {
      throw new UnauthorizedException('Este token não está válido');
    }
  }

  async login(user: Usuario): Promise<any> {
    const payload = { login: user.login, sub: user };
    return {
      codigo: user.codigo,
      codigoCadastroUnico: user.codigoCadastroUnico,
      nome: user.nome,
      token: this.jwtService.sign(payload),
    };
  }

  // gerarToken(usuario: Usuario): string {
  //   return jwt.sign({
  //     idUsuario: usuario._id,
  //     email: usuario.email
  //   }, this.configService.get('JWT_SECRET'), { expiresIn: '40min' })
  // }

  async authUser(login: string, senha: string): Promise<Usuario> {
     if (!login || login.trim() === '') {
      throw new BadRequestException('Email é obrigatório');
    }
    if (!senha || senha.trim() === '') {
      throw new BadRequestException('Senha é obrigatório');
    }

    const usuario: Usuario = await this.usuarioService.getByLogin(login);

    if (!usuario) {
      throw new UnauthorizedException('Usuário ou senha inválidos');
    }

    if (!this.securityService.validarSenha(senha, usuario.senha)) {
      throw new UnauthorizedException('Usuário ou senha inválidos');
    }

    // if(usuario.situacao !== ) {
    //   throw new UnauthorizedException('Usuário não se encontra ativo');
    // }

    return usuario;
  }

  // decodeToken(token: string): any {
  //   try {
  //     return jwt.verify(token, this.configService.get('JWT_SECRET'));
  //   } catch (error) {
  //     throw new BadRequestException('Token está inválido');
  //   }
  // }

}
