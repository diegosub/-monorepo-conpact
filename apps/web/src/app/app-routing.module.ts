import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { CONTENT_ROUTES } from './app-auth-routing.module';
import { LoginComponent } from './components/security/login/login.component';
import { NotfoundComponent } from './components/shared/notfound/notfound.component';
import { TemplateComponent } from './components/shared/template/template.component';


const appRoutes : Routes = [

    { path : '', component: TemplateComponent, data: { title: 'full Views' }, children: CONTENT_ROUTES },
    { path : 'login', component: LoginComponent },

    { path : '**', component: NotfoundComponent }

];

@NgModule({
  imports: [RouterModule.forRoot(appRoutes)],
  exports: [RouterModule]
})
export class AppRoutingModule {
}
