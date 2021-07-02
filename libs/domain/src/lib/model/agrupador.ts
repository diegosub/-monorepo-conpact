import { Base } from "./base";
import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity({ name: "tbl_agr", schema: "sc_cad" })
export class Agrupador {

  @PrimaryGeneratedColumn({ name: "cd_agr" })
  codigo: number;

  @Column({ name: "ds_agr" })
  descricao: string;

  @Column({ name: "cd_cun" })
  codigoCadastroUnico: number;

  @Column({ name: "fg_atv_agr" })
  ativo: boolean;

  @CreateDateColumn({ name: "dt_inc_agr" })
  dataInclusao: Date;

  @CreateDateColumn({ name: "dt_alt_agr" })
  dataAlteracao: Date;

  // @OneToOne(() => CadastroUnico)
  // cadastroUnico: CadastroUnico;

}
