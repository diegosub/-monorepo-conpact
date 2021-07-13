import { MensagemService } from './../shared/mensagem.service';

import { HttpErrorResponse } from '@angular/common/http';
import { Injectable } from '@angular/core';


@Injectable({
  providedIn: 'root'
})
export class ErrorService {

  constructor(private readonly mensagem: MensagemService) { }

  getClientErrorMessage(error: Error): string {
    return error.message ?
      error.message :
      error.toString();
  }

  getHttpErrorMessage(error: HttpErrorResponse): string {
    if (this.isHttpClientError(error.status)) {
      return error.error.message;
    }
    if (this.isHttpServerError(error.status)) {
      return 'Ocorreu um erro inesperado, favor tentar novamente.';

    } else {
      return 'Ocorreu um erro ao tentar acessar o nosso servidor, favor tentar novamente.'
    }

  }

  isHttpClientError(status: number): boolean {
    return status >= 400 && status <= 499;
  }

  isHttpServerError(status: number): boolean {
    return status >= 500 && status <= 599;
  }

  isUnauthorizedError(status: number): boolean {
    return status === 401;
  }

  isHttpError(error: Error | HttpErrorResponse): boolean {
    return error instanceof HttpErrorResponse;
  }

  showError(error: Error | HttpErrorResponse): void {

    if (error instanceof HttpErrorResponse) {
      console.log(error)
      const httpErrorMessage = this.getHttpErrorMessage(error);

      if (this.isUnauthorizedError(error.status)) {
        this.mensagem.msgErro(httpErrorMessage);

      } else {
        this.mensagem.msgErro(httpErrorMessage);
      }

    } else {
      const clientErrorMessage = this.getClientErrorMessage(error);
      this.mensagem.msgErro(clientErrorMessage);
    }
  }
}
