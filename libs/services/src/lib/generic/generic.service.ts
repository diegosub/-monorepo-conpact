import { InjectRepository } from "@nestjs/typeorm";
import { Connection, Entity, QueryRunner, Repository } from "typeorm";

export class GenericService<Entity> {

  constructor(
    @InjectRepository(Entity)
    protected readonly repository: Repository<Entity>,
    protected connection: Connection
  ) {}

  async getById(codigo: number): Promise<Entity> {
    return await this.repository.findOne(codigo);
  }

  async inserir(entity: Entity): Promise<Entity> {
    const queryRunner = this.connection.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      await this.validarInserir(queryRunner, entity);
      const retorno = await queryRunner.manager.save(entity);
      await queryRunner.commitTransaction();
      return retorno;
    } catch (err) {
      await queryRunner.rollbackTransaction();
      throw err;
    } finally {
      await queryRunner.release();
    }
  }

  async validarInserir(queryRunner: QueryRunner, entity: Entity) {}

  async alterar(codigo: number, entity: Entity): Promise<Entity> {
    const queryRunner = this.connection.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      await this.validarAlterar(queryRunner, entity);
      const retorno = await queryRunner.manager.save(entity);
      await queryRunner.commitTransaction();
      return retorno;
    } catch (err) {
      await queryRunner.rollbackTransaction();
      throw err;
    } finally {
      await queryRunner.release();
    }
  }

  protected async validarAlterar(queryRunner: QueryRunner, entity: Entity) {}

  async inativar(codigo: number): Promise<Entity> {
    const queryRunner = this.connection.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      const entity = await this.getById(codigo);
      this.inativarEntidade(entity)
      const retorno = await queryRunner.manager.save(entity);
      await queryRunner.commitTransaction();
      return retorno;
    } catch (err) {
      await queryRunner.rollbackTransaction();
      throw new Error(err);
    } finally {
      await queryRunner.release();
    }
  }

  inativarEntidade(entity: Entity) {}

  async ativar(codigo: number): Promise<Entity> {
    const queryRunner = this.connection.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      const entity = await this.getById(codigo);
      this.ativarEntidade(entity);
      const retorno = await queryRunner.manager.save(entity);

      await queryRunner.commitTransaction();
      return retorno;
    } catch (err) {
      await queryRunner.rollbackTransaction();
      throw new Error(err);
    } finally {
      await queryRunner.release();
    }
  }

  ativarEntidade(entity: Entity){}
}
