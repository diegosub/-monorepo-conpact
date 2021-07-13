import { HOST_SPG } from '../spg.api';
import { HttpClient, HttpParams } from '@angular/common/http';
import { GenericService } from './generic.service';
import { Injectable } from '@angular/core';

@Injectable()
export abstract class CrudService<Entity> implements GenericService<Entity>
{
  constructor(public http: HttpClient) { }

  get(codigo: number) {
    return this.http.get<Entity>(`${HOST_SPG}/api/` + this.strArtefato() + `/${codigo}`)
      .toPromise()
      .catch(function (error) { throw error });
  }

  pesquisar(entity) {
    const params = entity;

    return this.http.get<Entity[]>(`${HOST_SPG}/api/` + this.strArtefato(), { params })
      .toPromise()
      .catch(function (error) { throw error });
  }

  inserir(entity: Entity) {
    return this.http.post<Entity>(`${HOST_SPG}/api/` + this.strArtefato(), entity)
      .toPromise()
      .catch(function (error) { throw error });
  }


  alterar(codigo: number, entity: Entity) {
    return this.http.put<Entity>(`${HOST_SPG}/api/` + this.strArtefato() + `/${codigo}`, entity)
      .toPromise()
      .catch(function (error) { throw error });
  }

  ativar(codigo: number) {
    return this.http.put(`${HOST_SPG}/api/` + this.strArtefato() + `/ativar/${codigo}`, null)
      .toPromise()
      .catch(function (error) { throw error });
  }

  inativar(codigo: number) {
    return this.http.put(`${HOST_SPG}/api/` + this.strArtefato() + `/inativar/${codigo}`, null)
      .toPromise()
      .catch(function (error) { throw error });
  }

  strArtefato(): string { return null }
}
