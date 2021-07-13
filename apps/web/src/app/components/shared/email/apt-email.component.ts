import { Component, forwardRef, Input, OnInit } from '@angular/core';
import { ControlValueAccessor, NG_VALUE_ACCESSOR } from '@angular/forms';
import { DialogService } from 'src/app/services/shared/dialog.service';

const noop = () => {
};

export const EMAIL_CONTROL_VALUE_ACCESSOR: any = {
  provide: NG_VALUE_ACCESSOR,
  useExisting: forwardRef(() => AptEmailComponent),
  multi: true
};

@Component({
  selector: 'apt-email',
  templateUrl: './apt-email.component.html',
  styleUrls: ['./apt-email.component.css'],
  providers: [ EMAIL_CONTROL_VALUE_ACCESSOR ]
})
export class AptEmailComponent implements ControlValueAccessor, OnInit {

  @Input() isReadOnly;

  email: string;

  private onTouchedCallback: () => void = noop;
  private onChangeCallback: (_: any) => void = noop;


  constructor(private confirmDialogService: DialogService) { }

  ngOnInit() {
  }

  validarEmail() {
    let email = this.emailValor;

    if(email == null || email == '') {
      return;
    }

    let usuario = email.substring(0, email.indexOf("@"));
	  let dominio = email.substring(email.indexOf("@") + 1, email.length);
	
    if ((usuario.length >= 1) && (dominio.length >= 3)
        && (usuario.search("@") == -1) && (dominio.search("@") == -1)
        && (usuario.search(" ") == -1) && (dominio.search(" ") == -1)
        && (dominio.search(".") != -1) && (dominio.indexOf(".") >= 1)
        && (dominio.lastIndexOf(".") < dominio.length - 1))
    {
      return true;
    } 
    else
    {
      this.openPopupMsg("Este e-mail é inválido, favor informar um e-mail válido!");
      this.emailValor = '';
    }
  }

  get emailValor(): any {
    return this.email;
  };

  set emailValor(v: any) {
      if (v !== this.email) {
          this.email = v;
          this.onChangeCallback(v);
      }
  }

  openPopupMsg(msg) {
    this.confirmDialogService.openAlertDialog(msg)
    .afterClosed().subscribe(res =>{
      if(res){
        // Clique do OK

      }
    });
  }

  //From ControlValueAccessor interface
  writeValue(value: any) {
    if (value !== this.email) {
      this.emailValor = value;
    }
  }

  //From ControlValueAccessor interface
  registerOnChange(fn: any) {
    this.onChangeCallback = fn;
  }

  //From ControlValueAccessor interface
  registerOnTouched(fn: any) {
    this.onTouchedCallback = fn;
  }


}
