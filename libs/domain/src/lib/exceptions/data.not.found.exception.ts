import { AppException } from './app.exception';

export class DataNotFoundException extends AppException{

    constructor(message: string){
        super(message);
        this.name = 'DataNotFoundException';
    }
}