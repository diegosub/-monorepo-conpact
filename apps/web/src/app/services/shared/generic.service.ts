export interface GenericService<Entity>
{
    get(codigo);
    pesquisar(entity: Entity);
    inserir(entity: Entity);
    alterar(codigo: number, entity: Entity);
    ativar(codigo: number);
    inativar(codigo: number);
}
