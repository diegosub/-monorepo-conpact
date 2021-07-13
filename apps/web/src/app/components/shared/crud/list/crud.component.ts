import { EventEmitter } from "@angular/core";
import { FormArray, FormGroup } from "@angular/forms";

export abstract class CrudComponent {

  public carregando = new EventEmitter<boolean>(false);
  formulario: FormGroup;

  abstract submit();

  onSubmit() {
    if (this.formulario.valid) {
      this.submit();
    }
    else {
      this.verificaValidacoesForm(this.formulario);
    }
  }

  verificaValidacoesForm(formulario) {
    Object.keys(formulario.form.controls).forEach(campo => {
      const controle = formulario.form.get(campo);
      controle.markAsDirty();
      controle.markAsTouched();
      if (controle instanceof FormGroup || controle instanceof FormArray) {
        this.verificaValidacoesForm(controle);
      }
    });
  }

  resetar() {
    this.formulario.reset();
  }

  verificaValidDirty(campo) {
    return (!this.formulario.get(campo).valid
      && this.formulario.get(campo).dirty
      && this.formulario.get(campo).touched);
  }

  aplicaCssErro(campo: string) {
    return {
      'has-error': this.verificaValidDirty(campo),
      'has-feedback': this.verificaValidDirty(campo)
    };
  }

}
