import { HttpService } from './../http.service';
import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class AuthService
{
    constructor(public http: HttpService){}

    login(data: any) {
        return this.http.post('auth', data);
    }
}
