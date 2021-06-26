import { BaseModel } from './base.model';
import { IsBoolean, IsNotEmpty } from 'class-validator';
import { Exclude } from 'class-transformer';

export class Categoria extends BaseModel {

  @IsNotEmpty({message: "O campo Descrição é obrigatório."})
  descricao: string;

  @Exclude({ toPlainOnly: true })
  ativo: Boolean;

}
