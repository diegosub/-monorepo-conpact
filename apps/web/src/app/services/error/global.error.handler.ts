import { ErrorHandler, Injectable, Injector, Inject } from '@angular/core';
import { HttpErrorResponse } from '@angular/common/http';
import { ErrorService } from './error.service';


@Injectable()
export class GlobalErrorHandler extends ErrorHandler {

  constructor(@Inject(Injector) private injector: Injector) {
    super();
   }

  handleError(error: Error | HttpErrorResponse) {
    const errorService = this.injector.get(ErrorService);
    errorService.showError(error);
    super.handleError(error);
  }
}
