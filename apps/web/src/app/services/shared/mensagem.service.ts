import { Injectable } from '@angular/core';
import { ToastrService } from 'ngx-toastr';


@Injectable({
  providedIn: 'root'
})
export class MensagemService {

  constructor(private toastr: ToastrService) { }

  tratarErro(erro) {
    if (erro.error.userMessage != null) {
      this.toastr.error(erro.error.userMessage);
    }
    else {
      this.toastr.error('Ocorreu um erro inesperado com nosso servidor, tente novamente e se o erro persistir entre com contato com um administrador.', 'Opss..');
    }
  }

  msgErro(msg) {
    this.toastr.error(msg);
  }

  msgSucesso(msg) {
    this.toastr.success(msg);
  }

}
