import { HomeComponent } from './components/home/home.component';
import { Routes } from '@angular/router';
import { AuthGuard } from './components/security/auth.guard';

export const CONTENT_ROUTES: Routes = [

    { path: '', component: HomeComponent, canActivate: [AuthGuard] },
    { path: 'agrupador', loadChildren: () => import('./components/agrupador/agrupador.module').then(m => m.AgrupadorModule) },

];
