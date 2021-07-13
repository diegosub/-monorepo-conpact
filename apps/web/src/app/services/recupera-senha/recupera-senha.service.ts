import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';

@Injectable()
export class RecuperaSenhaService
{
  constructor(public http: HttpClient)
  {
  }

  // recuperarSenha(recuperaSenha: RecuperaSenha)
  // {
  //   return this.http.post(`${HOST_SPG}/api/recuperarSenha`, recuperaSenha)
  //                   .toPromise()
  //                   .catch(function(error) { throw error })
  // }

  // novaSenha(recuperaSenha: RecuperaSenha)
  // {
  //   return this.http.post(`${HOST_SPG}/api/novaSenha`, recuperaSenha)
  //                   .toPromise()
  //                   .catch(function(error) { throw error })
  // }

  // validarLink(recuperaSenha: RecuperaSenha)
  // {
  //   return this.http.post(`${HOST_SPG}/api/validarLink`, recuperaSenha)
  //                   .toPromise()
  //                   .catch(function(error) { throw error })
  // }
}
