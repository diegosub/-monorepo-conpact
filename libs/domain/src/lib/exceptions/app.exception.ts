
export class AppException extends Error{

    cause: object;
    name: string;

    constructor(mesage: string, cause?: object){
        super(mesage)
        this.cause = cause;
        this.name = 'AppException';
    }
}