import { AppException } from './app.exception';

export class SoapException extends AppException{

    constructor(message: string){
        super(message);
        this.name = 'SoapException';
    }
}
