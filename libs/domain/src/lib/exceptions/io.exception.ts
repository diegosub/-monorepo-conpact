import { AppException } from './app.exception';

export class IOException extends AppException{

    constructor(message: string, cause: object){
        super(message, cause);
        this.name = 'IOException';
    }
}