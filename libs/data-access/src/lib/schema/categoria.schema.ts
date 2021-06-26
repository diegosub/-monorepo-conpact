import { modelOptions, prop, Severity } from '@typegoose/typegoose';
import { BaseSchema } from './base.schema';

@modelOptions({ schemaOptions: { collection: 'categoria' }, options: { allowMixed: Severity.ALLOW, customName: 'Categoria' } })
export class CategoriaSchema extends BaseSchema {

  @prop({ type: String, required: true, trim: true })
  descricao: string;

  @prop({ type: Boolean, required: true })
  ativo: Boolean;

}
