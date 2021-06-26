import { AppException } from './app.exception';

export class BuilderException extends AppException{

    constructor(message: string){
        super(message);
        this.name = 'BuilderException';
    }
}
