import { AppException } from './app.exception';

export class DataRequiredException extends AppException{

    constructor(message: string){
        super(message);
        this.name = 'DataRequiredException';
    }
}
