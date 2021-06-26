import { AppException } from './app.exception';

export class TaskException extends AppException{

    constructor(message: string){
        super(message);
        this.name = 'TaskException';
    }
}
