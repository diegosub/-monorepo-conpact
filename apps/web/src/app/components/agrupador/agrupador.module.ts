import { AgrupadorAtualizarComponent } from './atualizar/agrupador-atualizar.component';
import { CommonModule } from '@angular/common';
import { HttpClientModule } from '@angular/common/http';
import { NgModule } from '@angular/core';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { MatDialogModule } from '@angular/material/dialog';
import { MatSortModule } from '@angular/material/sort';
import { MatTooltipModule } from '@angular/material/tooltip';
import { NgxMaskModule } from 'ngx-mask';
import { SharedModule } from '../../components/shared/shared.module';
import { AgrupadorRoutingModule } from './agrupador.routes';
import { AgrupadorPesquisarComponent } from './pesquisar/agrupador-pesquisar.component';

@NgModule({
    declarations: [
        AgrupadorPesquisarComponent,
        AgrupadorAtualizarComponent,
    ],
    imports: [
        FormsModule,
        ReactiveFormsModule,
        HttpClientModule,
        CommonModule,
        MatDialogModule,
        MatTooltipModule,
        MatSortModule,
        AgrupadorRoutingModule,
        NgxMaskModule.forRoot(),

        SharedModule
    ]
})
export class AgrupadorModule { }
