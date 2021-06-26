import { AppException } from './app.exception';

export class EmailException extends AppException {

  constructor(message: string, cause?: object) {
    super(message, cause);
    this.name = 'EmailException';
  }
}
