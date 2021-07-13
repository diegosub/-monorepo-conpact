import { HttpErrorResponse, HttpEvent, HttpHandler, HttpInterceptor, HttpRequest, HttpResponse } from "@angular/common/http";
import { EventEmitter, Injectable } from '@angular/core';
import { Router } from '@angular/router';
import { NgProgress, NgProgressRef } from 'ngx-progressbar';
import 'rxjs/add/operator/do';
import { Observable } from "rxjs/Observable";
import { UtilService } from './../../services/util.service';
import { catchError, finalize } from 'rxjs/operators';
import { throwError } from "rxjs";


@Injectable()
export class AuthInterceptor implements HttpInterceptor {

  public reenableButton = new EventEmitter<boolean>(false);
  public progressRef: NgProgressRef;

  constructor(private router: Router,
    private progress: NgProgress,
    private util: UtilService) {
  }

  intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {

    let authRequest: any;
    this.progressRef = this.progress.ref('progress');
    this.progressRef.start();

    if (this.util.isLoggedIn()) {
      let token = JSON.parse(localStorage.getItem("adminUsr")).token;

      authRequest = req.clone({
        setHeaders: {
          'Authorization': `Bearer ${token}`
        }
      });
    } else {
      authRequest = req.clone();
    }

    return next.handle(authRequest).pipe(
      catchError((error: HttpErrorResponse) => {
        this.progressRef.complete();

        if (error.status === 401) {
          localStorage.removeItem("adminUsr");
          this.router.navigate(['/login']);
        }
        console.log(123)
        return throwError(error);
      }),
      finalize(() => this.progressRef.complete())
    )
  }

}
