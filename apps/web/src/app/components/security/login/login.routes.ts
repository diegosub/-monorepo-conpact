import { Routes, RouterModule } from '@angular/router';
import { NgModule } from "@angular/core";
import { LoginComponent } from './login.component';

const appLoginRoutes : Routes = [

    { path : '', component: LoginComponent},

    { path : '**', redirectTo: "/" }

  ];

  @NgModule({
  imports: [RouterModule.forChild(appLoginRoutes)],
  exports: [RouterModule]
  })

  export class LoginRoutingModule {
  }
