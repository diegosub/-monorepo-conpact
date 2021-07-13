import { UtilService } from './../../../../services/util.service';
import { MensagemService } from './../../../../services/shared/mensagem.service';
import { DialogService } from './../../../../services/shared/dialog.service';
import { FormGroup } from '@angular/forms';
import { RemoteService } from './../../../../services/shared/remote.service';
import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';

@Component({
  template: ''
})
export class CrudListComponent<T> implements OnInit {

  lista = [];
  resource: string;
  formulario: FormGroup;

  constructor(
    protected readonly service: RemoteService,
    protected dialogService: DialogService,
    protected mensagem: MensagemService,
    protected router: Router,
    protected route: ActivatedRoute,
    protected util: UtilService
  ) {}

  ngOnInit() {
    this.criarForm();
    this.formulario.patchValue(this.util.inicioPaginaPesquisa(this.route));
    this.util.fimPaginaPesquisa();

    this.posIniciarPagina();
  }

  criarForm() {}

  posIniciarPagina() {}

  pesquisar() {
    this.service.pesquisar<T>(this.resource, this.formulario.value).subscribe (
      data => {
        this.lista = data;
      }
    );
  }

  ativar(codigo) {
    this.dialogService.openConfirmDialog('Deseja realmente reativar este registro?')
                      .afterClosed().subscribe(async res =>{
      if(res)
      {
        this.service.ativar(this.resource, codigo).subscribe(
          data => {
            this.mensagem.msgSucesso("O registro foi reativado com sucesso.");
            this.pesquisar();
          }
        )
      }
    });
  }

  inativar(codigo) {
    this.dialogService.openConfirmDialog('Deseja realmente inativar este registro?')
                      .afterClosed().subscribe(async res =>{
      if(res)
      {
        this.service.inativar(this.resource, codigo).subscribe(
          data => {
            this.mensagem.msgSucesso("O registro foi inativado com sucesso.");
            this.pesquisar();
          }
        )
      }
    });
  }

  visualizar(codigo)
  {
    this.util.setarObjetoBack(this.formulario.value);
    this.router.navigate([`/${this.resource}/visualizar`], {queryParams: {codigo: codigo}});
  }

  alterar(codigo)
  {
    this.util.setarObjetoBack(this.formulario.value);
    this.router.navigate([`/${this.resource}/atualizar`], {queryParams: {codigo: codigo}});
  }

}
