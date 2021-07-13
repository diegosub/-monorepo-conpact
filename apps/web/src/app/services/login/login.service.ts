import { Usuario, UsuarioLoginDto } from '@admin/domain';
import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { HOST_SPG } from '../spg.api';


@Injectable({
  providedIn: 'root'
})
export class LoginService
{
    constructor(public http: HttpClient){}

    login(usuario: UsuarioLoginDto): Promise<Usuario>
    {
        return this.http.post<Usuario>(`${HOST_SPG}/api/auth`, usuario)
                        .toPromise()
                        .catch(function (error) { throw error });
    }
}
