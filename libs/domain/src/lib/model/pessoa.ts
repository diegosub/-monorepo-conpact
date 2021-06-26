import { IsBoolean, IsDateString, IsEmail, IsIn, IsMobilePhone, IsNotEmpty } from 'class-validator';
import { Perfil } from '../enum/perfil';
import { BaseModel } from './base.model';

export class Pessoa extends BaseModel {

  @IsNotEmpty({message: "O campo Nome é obrigatório."})
  nome: string;

  @IsEmail({}, {message: "O campo Email é obrigatório e deve ser válido."})
  email: string;

  @IsNotEmpty({ message: 'O CPF é obrigatório' })
  cpf: string;

  @IsIn(['MASCULINO', 'FEMININO'], { message: 'Sexo é obrigatório e deverá ser MASCULINO ou FEMINNO' })
  sexo: string;

  @IsMobilePhone(null, {}, { message: 'O Celular é obrigatório e deverá está válido' })
  celular: string;

  @IsDateString({}, { message: 'A Data de Nascimento é obrigatória e deve ser válida' })
  dataNascimento: Date;

  @IsIn(Object.values(Perfil), { message: `Perfil é obrigatório e deverá ser um dos valores : ${Object.values(Perfil)}` })
  perfil: Perfil;

  @IsBoolean({ message: 'Ativo é obrigatório deverá ser verdadeiro ou falso' })
  ativo: boolean;

}
