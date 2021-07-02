import { Exclude, Expose } from "class-transformer";
import { IsNotEmpty } from 'class-validator';

@Exclude()
export class AgrupadorAlterarDto {

  @Expose()
  @IsNotEmpty({ message: 'Descrição obrigatória.' })
  descricao: string;

  // Preenchidos pelo sistema

  @Exclude()
  dataAlteracao: Date;

}
