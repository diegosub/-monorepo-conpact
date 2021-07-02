import { Column, CreateDateColumn, UpdateDateColumn } from "typeorm";

export class Base {
  @Column({name: "cd_inc_usr"})
  codigoUsuarioInclusao: number;

  @Column({name: "cd_alt_usr"})
  codigoUsuarioAlteracao: number;

  @CreateDateColumn({name: "dt_inc_usr", type: "timestamp"})
  dataInclusao: Date;

  @UpdateDateColumn({name: "dt_alt_usr", type: "timestamp"})
  dataAlteracao: Date;
}
