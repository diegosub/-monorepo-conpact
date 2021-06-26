import { AppException } from './app.exception';

export class XMLException extends AppException{

    constructor(message: string){
        super(message);
        this.name = 'XMLException';
    }
}
