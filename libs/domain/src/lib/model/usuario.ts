import { Pessoa } from './pessoa';

export class Usuario extends Pessoa {

  senha: string;
  dataExpiracaoSenha: Date;
  dataAtivacao: Date;

}
