import { modelOptions, prop, Severity } from '@typegoose/typegoose';
import { PessoaSchema } from './pessoa.schema';

@modelOptions({ schemaOptions: { collection: 'usuario' }, options: { allowMixed: Severity.ALLOW, customName: 'Usuario' } })
export class UsuarioSchema extends PessoaSchema {

  @prop({ type: String, required: false, trim: true })
  senha: string;

  @prop({ type: Date, required: false })
  dataExpiracaoSenha: Date;

  @prop({ type: Date, required: false })
  dataAtivacao: Date;
}
