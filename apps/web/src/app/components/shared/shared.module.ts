import { DialogService } from '../../services/shared/dialog.service';
import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MatDialogModule } from '@angular/material/dialog';
import { LoadingButton } from '../../diretivas/loading/loading-button';
import { Moeda } from '../../pipes/moeda';
import { DialogComponent } from './dialog/dialog.component';
import { MsgErrorComponent } from './msg-error/msg-error.component';

@NgModule({
    declarations: [
        Moeda,
        LoadingButton,
        DialogComponent,
        MsgErrorComponent,
        //FilterPipe,
        //CpfComponent,
        // SoNumero,
    ],
    imports: [
        FormsModule,
        CommonModule,
        MatDialogModule,
      ],
    exports: [
        Moeda,
        DialogComponent,
        MsgErrorComponent,
        LoadingButton
        //FilterPipe,
        // SoNumero,
    ],
    providers: [
        DialogService
    ]
})
export class SharedModule { }
