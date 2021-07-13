import { Observable } from 'rxjs/Observable';
import { Injectable } from '@angular/core';
import { Route, Router, CanActivate, ActivatedRouteSnapshot, RouterStateSnapshot, CanLoad } from '@angular/router';
import { UtilService } from '../../services/util.service';


@Injectable({ providedIn: 'root' })
export class AuthGuard implements CanActivate {

  constructor(private router: Router,
    private util: UtilService) { }

  canActivate(route: ActivatedRouteSnapshot,
    state: RouterStateSnapshot): Observable<boolean> | boolean {

    if (this.util.isLoggedIn()) {
      return true;
    }

    this.router.navigate(['/login']);
    return false;
  }

}
