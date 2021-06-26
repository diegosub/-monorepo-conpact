import { BadRequestException, NotFoundException, UnauthorizedException } from '@nestjs/common';
import { ErrorType } from './error.type';
import { PayloadError } from './payload.error';

export class PayloadErrorBuilder {

  error: Error;
  MSG_GENERICA = "Ocorreu um erro inesperado no sistema. Tente novamente e se o problema persistir, entre em contato com um administrador.";

  constructor(error: Error) {
    this.error = error;
  }

  build(): PayloadError {

    if (this.error instanceof BadRequestException) {
      const response: any = this.error.getResponse();
      return this.createPayloadError(this.error.getStatus(),
        ErrorType.DADOS_INVALIDOS,
        "Um ou mais campos estão inválidos. Faça o preenchimento correto e tente novamente.",
        response.message);
    } else {
      if (this.error instanceof UnauthorizedException) {
        const response: any = this.error.getResponse();
        return this.createPayloadError(this.error.getStatus(),
          ErrorType.ERRO_AUTENTICACAO,
          response.message);
      } else {
        if (this.error instanceof NotFoundException) {
          const response: any = this.error.getResponse();
          return this.createPayloadError(this.error.getStatus(),
            ErrorType.RECURSO_NAO_ENCONTRADO,
            response.message);
        } else {
          return this.createPayloadError(500,
            ErrorType.ERRO_DE_SISTEMA,
            this.MSG_GENERICA);
        }
      }
    }
  }

  createPayloadError(status: number, type: string, message: string, objects?: []): PayloadError {

    const payload = new PayloadError();

    payload.status = status;
    payload.type = type;
    payload.message = message;
    payload.objects = objects;
    payload.timestamp = new Date().toLocaleString();

    return payload;

  }
}
