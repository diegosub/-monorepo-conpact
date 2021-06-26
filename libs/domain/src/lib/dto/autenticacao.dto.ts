import { Perfil } from '../enum';

export interface AutenticacaoDTO {
  nome?: string;
  token?: string;
  perfil?: Perfil;
}
