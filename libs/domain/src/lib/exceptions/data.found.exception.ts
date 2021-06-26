import { AppException } from './app.exception';

export class DataFoundException extends AppException{

    constructor(message: string){
        super(message);
        this.name = 'DataFoundException';
    }
}