import { Perfil } from '@admin/domain';
import { modelOptions, prop, Severity } from '@typegoose/typegoose';
import { BaseSchema } from './base.schema';

@modelOptions({ schemaOptions: { collection: 'usuario' }, options: { allowMixed: Severity.ALLOW, customName: 'Pessoa' } })
export class PessoaSchema extends BaseSchema {

  @prop({ type: String, required: true, trim: true })
  cpf: string;

  @prop({ type: String, required: true, trim: true })
  nome: string;

  @prop({ type: String, required: true, trim: true })
  sexo: string;

  @prop({ type: String, trim: true })
  celular: string;

  @prop({ type: Date })
  dataNascimento: Date;

  @prop({ type: String })
  email: string;

  @prop({ enum: Perfil, type: String })
  perfil: Perfil;

  @prop({ type: Boolean, required: false })
  ativo: boolean;

}
