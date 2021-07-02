import { SecurityService } from '../security/security.service';
import { UsuarioService } from '../usuario/usuario.service';
import { BadRequestException, Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { Usuario } from '@admin/domain';


@Injectable()
export class AuthService {

  constructor(
    private readonly configService: ConfigService,
    private readonly jwtService: JwtService,
    private readonly usuarioService: UsuarioService,
    private readonly securityService: SecurityService,
  ) { }

  // async validateUser(username: string, pass: string): Promise<Usuario> {
  //   return await this.authUser(username, pass);
  // }

  async login(user: Usuario): Promise<any> {
    const payload = { email: user.login, sub: user };
    return {
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

  async authUser(email: string, senha: string): Promise<Usuario> {
     if (!email || email.trim() === '') {
      throw new BadRequestException('Email é obrigatório');
    }
    if (!senha || senha.trim() === '') {
      throw new BadRequestException('Senha é obrigatório');
    }

    const usuario = await this.usuarioService.getByEmail(email);
    // if (!usuario) {
    //   throw new UnauthorizedException('Usuário ou senha inválidos');
    // }
    // if (usuario.situacao !== SituacaoUsuario.ATIVO) {
    //   throw new UnauthorizedException('Usuário não está ativo');
    // }
    // if (!this.securityService.validarSenha(senha, usuario.senha)) {
    //   throw new UnauthorizedException('Usuaário ou senha inválidos');
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
