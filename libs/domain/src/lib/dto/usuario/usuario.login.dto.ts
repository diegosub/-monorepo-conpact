import { Exclude, Expose } from "class-transformer";
import { IsNotEmpty } from "class-validator";

@Exclude()
export class UsuarioLoginDto {

  @Expose()
  @IsNotEmpty({ message: 'O Usuário é obrigatório.' })
  username: string;

  @Expose()
  @IsNotEmpty({ message: 'A senha é obrigatória.' })
  password: string;
}
