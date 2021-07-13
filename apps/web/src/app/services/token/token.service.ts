import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { HOST_SPG } from '../spg.api';

@Injectable()
export class TokenService {

  constructor(private http: HttpClient) {}

  validateAuthenticationToken(login: string, token: string){
    let headers = new HttpHeaders().set('Authorization', token);
    return this.http.post(`${HOST_SPG}/api/validate`, login, {headers});
  }

}
