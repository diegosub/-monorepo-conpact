import { Exclude, Expose } from "class-transformer";
import { IsNotEmpty } from 'class-validator';

@Exclude()
export class AgrupadorInserirDto {

  @Expose()
  @IsNotEmpty({ message: 'Descrição obrigatória.' })
  descricao: string;

  @Expose()
  @IsNotEmpty({ message: 'Cadastro Único obrigatório.' })
  codigoCadastroUnico: number;

}
