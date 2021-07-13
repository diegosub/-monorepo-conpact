import { HttpService } from './../http.service';
import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class RemoteService
{
  constructor(public http: HttpService) { }

  obterPorCodigo<Entity>(resource: string, codigo: number) {
    return this.http.get<Entity>(`${resource}/${codigo}`, null);
  }

  pesquisar<Entity>(resource: string, filtro: any) {
    return this.http.get<Entity[]>(resource, filtro);
  }

  inserir<Entity>(resource: string, entity: Entity) {
    return this.http.post<Entity>(resource, entity);
  }


  alterar<Entity>(resource: string, codigo: number, entity: Entity) {
    return this.http.put<Entity>(`${resource}/${codigo}`, entity);
  }

  ativar<Entity>(resource: string, codigo: number) {
    return this.http.put(`${resource}/ativar/${codigo}`, null);
  }

  inativar<Entity>(resource: string, codigo: number) {
    return this.http.put(`${resource}/inativar/${codigo}`, null);
  }
}
