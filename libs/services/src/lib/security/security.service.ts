import {
  Injectable
} from '@nestjs/common';
import * as bcrypt from 'bcryptjs';
import * as generatePassword from 'generate-password';

@Injectable()
export class SecurityService {
  constructor() {}

  cryptSenha(valor: string): string {
    return bcrypt.hashSync(valor, bcrypt.genSaltSync(10));
  }

  gerarSenhaAleatoria(): string {
    return this.generatePassword();
  }

  validarSenha(valor: string, valorCrypt: string): boolean {
    return bcrypt.compareSync(valor, valorCrypt);
  }

  generatePassword(): string {
    return generatePassword.generate({
      length: 8,
      numbers: true,
      symbols: false,
      uppercase: true,
      strict: true
    });
  }
}
