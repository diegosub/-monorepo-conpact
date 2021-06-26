import { AppException } from './app.exception';

export class AutorizacaoException extends AppException{

    constructor(message: string){
        super(message);
        this.name = 'AutorizacaoException';
    }
}