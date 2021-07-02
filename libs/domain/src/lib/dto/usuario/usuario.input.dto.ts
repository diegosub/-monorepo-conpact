import { Exclude, Expose } from 'class-transformer';

@Exclude()
export class UsuarioInputDto {

  @Expose()
  nome: string;

}
