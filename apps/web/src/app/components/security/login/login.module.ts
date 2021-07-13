import { HttpClientModule } from '@angular/common/http';
import { CommonModule } from '@angular/common';

import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { SharedModule } from './../../shared/shared.module';
import { LoginComponent } from './login.component';
import { LoginRoutingModule } from './login.routes';

@NgModule({
    declarations: [
        LoginComponent,
    ],
    imports: [
        FormsModule,
        HttpClientModule,
        CommonModule,
        LoginRoutingModule,

        SharedModule
    ]
})
export class LoginModule { }
