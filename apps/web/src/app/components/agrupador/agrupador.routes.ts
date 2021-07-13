import { NgModule } from "@angular/core";
import { RouterModule, Routes } from "@angular/router";
import { AuthGuard } from '../../components/security/auth.guard';
import { AgrupadorAtualizarComponent } from './atualizar/agrupador-atualizar.component';
import { AgrupadorPesquisarComponent } from './pesquisar/agrupador-pesquisar.component';

const appAgrupadorRoutes : Routes = [

  { path : '', component: AgrupadorPesquisarComponent, canActivate: [AuthGuard]},
  { path : 'atualizar', component: AgrupadorAtualizarComponent, canActivate: [AuthGuard]},

    { path : '**', redirectTo: "/" }

  ];

  @NgModule({
  imports: [RouterModule.forChild(appAgrupadorRoutes)],
  exports: [RouterModule]
  })

  export class AgrupadorRoutingModule {
  }
