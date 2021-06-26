import { AppException } from './app.exception';

export class PermissaoException extends AppException{

    constructor(message: string){
        super(message);
        this.name = 'PermissaoException';
    }
}