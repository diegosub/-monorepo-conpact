import { InjectRepository } from "@nestjs/typeorm";
import { Connection, Entity, QueryRunner, Repository } from "typeorm";

export class GenericService<Entity> {

  constructor(
    @InjectRepository(Entity)
    protected readonly repository: Repository<Entity>,
    protected connection: Connection
  ) { }

  async getById(codigo: number): Promise<Entity> {
    return await this.repository.findOne(codigo);
  }

  async inserir(entity: Entity): Promise<Entity> {
    await this.validarInserir(entity);
    const retorno = await this.repository.save(entity);
    return retorno;
  }

  async validarInserir(entity: Entity) { }

  async alterar(entity: Entity): Promise<Entity> {
    await this.validarAlterar(entity);
    const retorno = await this.repository.save(entity);
    return retorno;
  }

  protected async validarAlterar(entity: Entity) { }

  async inativar(codigo: number): Promise<Entity> {
    const entity: any = { codigo: codigo };
    this.inativarEntidade(entity)
    const retorno = await this.repository.save(entity);
    return retorno;
  }

  inativarEntidade(entity: Entity) { }

  async ativar(codigo: number): Promise<Entity> {
    const entity: any = { codigo: codigo };
    this.ativarEntidade(entity);
    const retorno = await this.repository.save(entity);
    return retorno;
  }

  ativarEntidade(entity: Entity) { }
}
