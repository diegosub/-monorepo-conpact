import { Base } from './base';
import { Column, Entity, PrimaryColumn, PrimaryGeneratedColumn } from 'typeorm';

@Entity({name: "tbl_usr", schema: "sc_sgr"})
export class Usuario extends Base {

  @PrimaryGeneratedColumn({name: "cd_usr"})
  codigo: number;

  @Column({name: "nm_usr"})
  nome: string;

  @Column({name: "lgn_usr"})
  login: string;

  @Column({name: "snh_usr"})
  senha: string;

  @Column({name: "cd_cun"})
  codigoCadastroUnico: number;

  @Column({name: "st_usr"})
  situacao: number;

  @Column({name: "fg_adm_usr", type: "boolean"})
  flagAdministrador: boolean;

  @Column({name: "fg_cad_gml_usr", type: "boolean"})
  flagCadastroGmail;

  @Column({name: "fg_cad_nrm_usr", type: "boolean"})
  flagCadastroNormal;
}
