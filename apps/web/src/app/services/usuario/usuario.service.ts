import { Usuario } from '@admin/domain';
import { Injectable } from '@angular/core';
import { HOST_SPG } from '../spg.api';
import { CrudService } from '../shared/crud.service';


@Injectable()
export class UsuarioService extends CrudService<Usuario>
{
  login(usuario: Usuario)
  {
    return this.http.post(`${HOST_SPG}/api/auth`, usuario)
                    .toPromise()
                    .catch(function(error) { throw error })
  }

  editarPerfil(id: number, usuario: Usuario)
  {
    return this.http.put(`${HOST_SPG}/api/`+this.strArtefato()+`/editarPerfil/${id}`, usuario)
                    .toPromise()
                    .catch(function(error) { throw error })
  }

  redefinirSenha(usuario: Usuario)
  {
    return this.http.put(`${HOST_SPG}/api/`+this.strArtefato()+`/redefinirSenha`, usuario)
                    .toPromise()
                    .catch(function(error) { throw error })
  }

  recuperarSenha(usuario: Usuario)
  {
    return this.http.post(`${HOST_SPG}/api/`+this.strArtefato()+`/recuperarSenha`, usuario)
                    .toPromise()
                    .catch(function(error) { throw error })
  }

  refresh()
  {
    return this.http.post(`${HOST_SPG}/api/auth/refresh`, null)
                    .toPromise()
                    .catch(function(error) { throw error })
  }

  strArtefato(): string
  {
    return "usuario";
  }
}
