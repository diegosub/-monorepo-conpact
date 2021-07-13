import { Exclude, Expose } from 'class-transformer';

@Exclude()
export class UsuarioInputDto {

  @Expose()
  codigo: number;

  @Expose()
  nome: string;

  @Expose()
  login: string;

  @Expose()
  email: string;

  @Expose()
  codigoCadastroUnico: string;

}
