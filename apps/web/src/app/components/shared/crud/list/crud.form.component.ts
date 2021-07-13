import { UtilService } from './../../../../services/util.service';
import { MensagemService } from './../../../../services/shared/mensagem.service';
import { DialogService } from './../../../../services/shared/dialog.service';
import { FormGroup } from '@angular/forms';
import { RemoteService } from './../../../../services/shared/remote.service';
import { Component, OnInit } from '@angular/core';
import { Router, ActivatedRoute } from '@angular/router';
import { CrudComponent } from './crud.component';
import { finalize } from 'rxjs/operators';

@Component({
  template: ''
})
export class CrudFormComponent<T> extends CrudComponent implements OnInit {

  resource: string;
  codigo: number;

  constructor(
    protected readonly service: RemoteService,
    protected mensagem: MensagemService,
    protected router: Router,
    protected route: ActivatedRoute,
  ) {
    super();
  }

  ngOnInit() {
    this.popularListas();
    this.criarForm();

    this.codigo = this.route.snapshot.queryParams['codigo'];

    if(this.codigo) {
      this.carregarForm();
    }
  }

  popularListas() {}

  criarForm() {}

  carregarForm(): void {
    if (this.codigo) {
      this.service.obterPorCodigo<T>(this.resource, this.codigo).subscribe(
        data => {
          this.populateForm(data);
          this.posCarregarForm(data);
        }
      )
    }
  }

  populateForm(data: T): void {
    this.formulario.patchValue(data);
  }

  posCarregarForm(data: T) {}


  submit() {
    if (!this.codigo) {
      this.inserir();
    }
    else {
      this.alterar();
    }
  }

  inserir() {
    console.log(this.formulario.value)
    this.service.inserir(this.resource, this.formulario.value)
    .pipe(finalize(() => {this.carregando.emit(false)})).subscribe(
      data => {
        this.executarPosInserir();
        this.mensagem.msgSucesso("O registro foi inserido com sucesso.");
      }
    )
  }

  executarPosInserir() {
    this.router.navigate([`/${this.resource}`]);
  }

  alterar() {
    this.service.alterar(this.resource, this.codigo, this.formulario.value)
    .pipe(finalize(() => {this.carregando.emit(false)})).subscribe(
      data => {
        this.executarPosAlterar();
        this.mensagem.msgSucesso("O registro foi alterado com sucesso.");
      }
    )
  }

  executarPosAlterar() {
    this.router.navigate([`/${this.resource}`]);
  }


}
