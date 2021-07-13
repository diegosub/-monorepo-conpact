import { Component, EventEmitter, forwardRef, Input, OnInit, Output } from '@angular/core';
import { ControlValueAccessor, NG_VALUE_ACCESSOR } from '@angular/forms';


const noop = () => {
};

export const CPF_CONTROL_VALUE_ACCESSOR: any = {
  provide: NG_VALUE_ACCESSOR,
  useExisting: forwardRef(() => CpfComponent),
  multi: true
};

@Component({
  selector: 'cpf',
  templateUrl: './cpf.component.html',
  styleUrls: ['./cpf.component.css'],
  providers: [ CPF_CONTROL_VALUE_ACCESSOR ]
})
export class CpfComponent implements ControlValueAccessor, OnInit {

  @Input() isReadOnly;

  cpf: string;

  private onTouchedCallback: () => void = noop;
  private onChangeCallback: (_: any) => void = noop;


  constructor() { }

    ngOnInit() {
    }

    validarCpf() {

      if (this.cpfValor == null || this.cpfValor == '') {
        return;
      }

      let reg1 = /\./gi;
      let reg2 = /\-/gi;
      let str1 = this.cpfValor.replace(reg1,"");
      let cpf = str1.replace(reg2, "");

      if (cpf.length != 11) {
        // this.dialogService.openAlertDialog('Este CPF é inválido, favor informar um CPF válido.');
        this.cpfValor = '';
        return;
      }

      if ((cpf == '00000000000') || (cpf == '11111111111') || (cpf == '22222222222') || (cpf == '33333333333') || (cpf == '44444444444') || (cpf == '55555555555') || (cpf == '66666666666') || (cpf == '77777777777') || (cpf == '88888888888') || (cpf == '99999999999')) {
        //this.dialogService.openAlertDialog('Este CPF é inválido, favor informar um CPF válido.');
        this.cpfValor = '';
        return;
      }

      let numero: number = 0;
      let caracter: string = '';
      let numeros: string = '0123456789';
      let j: number = 10;
      let somatorio: number = 0;
      let resto: number = 0;
      let digito1: number = 0;
      let digito2: number = 0;
      let cpfAux: string = '';
      cpfAux = cpf.substring(0, 9);
      for (let i: number = 0; i < 9; i++) {
          caracter = cpfAux.charAt(i);
          if (numeros.search(caracter) == -1) {
              return false;
          }
          numero = Number(caracter);
          somatorio = somatorio + (numero * j);
          j--;
      }
      resto = somatorio % 11;
      digito1 = 11 - resto;
      if (digito1 > 9) {
          digito1 = 0;
      }
      j = 11;
      somatorio = 0;
      cpfAux = cpfAux + digito1;
      for (let i: number = 0; i < 10; i++) {
          caracter = cpfAux.charAt(i);
          numero = Number(caracter);
          somatorio = somatorio + (numero * j);
          j--;
      }
      resto = somatorio % 11;
      digito2 = 11 - resto;
      if (digito2 > 9) {
          digito2 = 0;
      }
      cpfAux = cpfAux + digito2;
      if (cpf != cpfAux) {
        this.cpfValor = '';
        //this.dialogService.openAlertDialog('Este CPF é inválido, favor informar um CPF válido.');
        return;
      }
    }

    get cpfValor(): any {
      return this.cpf;
    };

    set cpfValor(v: any) {
        if (v !== this.cpf) {
            this.cpf = v;
            this.onChangeCallback(v);
        }
    }

    openPopupMsg(msg) {
      // this.dialogService.openAlertDialog(msg)
      // .afterClosed().subscribe(res =>{
      //   if(res){
      //     // Clique do OK

      //   }
      // });
    }

    //From ControlValueAccessor interface
    writeValue(value: any) {
      if (value !== this.cpf) {
        this.cpfValor = value;
        //console.log(this.cpfValor);
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
