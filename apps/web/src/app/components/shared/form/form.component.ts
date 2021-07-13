import { RemoteService } from './../../../services/shared/remote.service';
import { ActivatedRoute, Route } from '@angular/router';
import { AfterViewInit, EventEmitter, OnInit } from '@angular/core';
import { FormArray, FormGroup } from '@angular/forms';

export abstract class FormComponent {

  public carregando = new EventEmitter<boolean>(false);
  formulario: FormGroup;

  listaUf = [];
  listaDia = [];
  listaMes = [];

  codigo: number;

  constructor(
    protected route: ActivatedRoute,
    protected readonly service: RemoteService
  ) { }

  abstract submit();

  obterCodigo() {
    this.codigo = this.route.snapshot.queryParams['codigo'];
  }

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

  setListasStaticas() {
    if (this.listaUf.length == 0) {
      this.listaUf.push({ nome: "AC", valor: "AC" });
      this.listaUf.push({ nome: "AL", valor: "AL" });
      this.listaUf.push({ nome: "AP", valor: "AP" });
      this.listaUf.push({ nome: "AM", valor: "AM" });
      this.listaUf.push({ nome: "BA", valor: "BA" });
      this.listaUf.push({ nome: "CE", valor: "CE" });
      this.listaUf.push({ nome: "DF", valor: "DF" });
      this.listaUf.push({ nome: "ES", valor: "ES" });
      this.listaUf.push({ nome: "GO", valor: "GO" });
      this.listaUf.push({ nome: "MA", valor: "MA" });
      this.listaUf.push({ nome: "MT", valor: "MT" });
      this.listaUf.push({ nome: "MS", valor: "MS" });
      this.listaUf.push({ nome: "MG", valor: "MG" });
      this.listaUf.push({ nome: "PA", valor: "PA" });
      this.listaUf.push({ nome: "PB", valor: "PB" });
      this.listaUf.push({ nome: "PR", valor: "PR" });
      this.listaUf.push({ nome: "PE", valor: "PE" });
      this.listaUf.push({ nome: "PI", valor: "PI" });
      this.listaUf.push({ nome: "RR", valor: "RR" });
      this.listaUf.push({ nome: "RO", valor: "RO" });
      this.listaUf.push({ nome: "RJ", valor: "RJ" });
      this.listaUf.push({ nome: "RN", valor: "RN" });
      this.listaUf.push({ nome: "RS", valor: "RS" });
      this.listaUf.push({ nome: "SC", valor: "SC" });
      this.listaUf.push({ nome: "SP", valor: "SP" });
      this.listaUf.push({ nome: "SE", valor: "SE" });
      this.listaUf.push({ nome: "TO", valor: "TO" });
    }

    if (this.listaDia.length == 0) {
      this.listaDia.push({ nome: "Domingo", valor: 0, nomeReduzido: "Domingo" });
      this.listaDia.push({ nome: "Segunda-Feira", valor: 1, nomeReduzido: "Segunda" });
      this.listaDia.push({ nome: "Terça-Feira", valor: 2, nomeReduzido: "Terça" });
      this.listaDia.push({ nome: "Quarta-Feira", valor: 3, nomeReduzido: "Quarta" });
      this.listaDia.push({ nome: "Quinta-Feira", valor: 4, nomeReduzido: "Quinta" });
      this.listaDia.push({ nome: "Sexta-Feira", valor: 5, nomeReduzido: "Sexta" });
      this.listaDia.push({ nome: "Sábado", valor: 6, nomeReduzido: "Sábado" });
    }

    if (this.listaMes.length == 0) {
      this.listaMes.push({ nome: "Janeiro", valor: 1 });
      this.listaMes.push({ nome: "Fevereiro", valor: 2 });
      this.listaMes.push({ nome: "Março", valor: 3 });
      this.listaMes.push({ nome: "Abril", valor: 4 });
      this.listaMes.push({ nome: "Maio", valor: 5 });
      this.listaMes.push({ nome: "Junho", valor: 6 });
      this.listaMes.push({ nome: "Julho", valor: 7 });
      this.listaMes.push({ nome: "Agosto", valor: 8 });
      this.listaMes.push({ nome: "Setembro", valor: 9 });
      this.listaMes.push({ nome: "Outubro", valor: 10 });
      this.listaMes.push({ nome: "Novembro", valor: 11 });
      this.listaMes.push({ nome: "Dezembro", valor: 12 });
    }
  }

}
