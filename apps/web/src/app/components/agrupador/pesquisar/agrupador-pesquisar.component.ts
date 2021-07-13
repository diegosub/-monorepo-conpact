import { FormBuilder } from '@angular/forms';
import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { DialogService } from '../../../services/shared/dialog.service';
import { MensagemService } from '../../../services/shared/mensagem.service';
import { UtilService } from '../../../services/util.service';
import { Agrupador } from './../../../../../../../libs/domain/src/lib/model/agrupador';
import { RemoteService } from './../../../services/shared/remote.service';
import { CrudListComponent } from './../../shared/crud/list/crud.list.component';

@Component({
  selector: 'app-agrupador-pesquisar',
  templateUrl: './agrupador-pesquisar.component.html',
  styleUrls: ['./agrupador-pesquisar.component.css']
})
export class AgrupadorPesquisarComponent extends CrudListComponent<Agrupador> implements OnInit
{
  constructor(
    public router: Router,
    private formBuilder: FormBuilder,
    public mensagem: MensagemService,
    public util: UtilService,
    public dialogService: DialogService,
    public route: ActivatedRoute,
    protected readonly service: RemoteService) {
      super(service, dialogService, mensagem, router, route, util);
      this.resource = "agrupador";
  }

  criarForm() {
    this.formulario = this.formBuilder.group({
      descricao: [''],
      ativo: ['']
    });
  }

  posIniciarPagina() {
    this.pesquisar();
  }
}
