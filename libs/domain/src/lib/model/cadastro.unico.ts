import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';
import { Base } from './base';

@Entity({name: "tbl_cun", schema: "sc_cuc"})
export class CadastroUnico extends Base {

  @PrimaryGeneratedColumn({name: "CD_CUN"})
  codigo: number;

  @Column({name: "NM_CUN"})
  nome: string;

  @Column({name: "EML_CUN"})
  email: string;

  @Column({name: "TP_PSS_CUN"})
  tipoPessoa: string;

  @Column({name: "NR_CPF_CNPJ_CUN"})
  cpfCnpj: number;

  @Column({name: "FT_CUN"})
  foto: string;

}
