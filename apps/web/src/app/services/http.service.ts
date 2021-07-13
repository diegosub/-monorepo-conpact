
import { Injectable } from '@angular/core';
import { HttpClient, HttpParams, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { EnvironmentService } from './environment.service';

@Injectable({
  providedIn: 'root'
})
export class HttpService {

  apiUrl: string;

  constructor(
    private readonly httpClient: HttpClient,
    private readonly environmentService: EnvironmentService
  ) {
    this.apiUrl = this.environmentService.getValue('apiUrl');
    console.log(this.apiUrl)
  }

  get<T>(resource: string, params): Observable<T> {
    return this.httpClient.get<T>(`${this.apiUrl}${resource}`, {params});
  }

  post<T>(resource: string, body: any, options?: {
    headers?: HttpHeaders | {
      [header: string]: string | string[];
    };
    params?: HttpParams | {
      [param: string]: string | string[];
    };
  }): Observable<T> {
    return this.httpClient.post<T>(`${this.apiUrl}${resource}`, body, options);
  }

  put<T>(resource: string, body: any, options?: {
    headers?: HttpHeaders | {
      [header: string]: string | string[];
    };
    params?:  HttpParams |  {
      [param: string]: string | string[];
    };
  }): Observable<T> {
    return this.httpClient.put<T>(`${this.apiUrl}${resource}`, body, options);
  }

  delete<T>(resource: string, options?: {
    headers?: HttpHeaders | {
      [header: string]: string | string[];
    };
    params?: HttpParams | {
      [param: string]: string | string[];
    };
  }): Observable<T> {
    return this.httpClient.delete<T>(`${this.apiUrl}${resource}`, options);
  }
}
