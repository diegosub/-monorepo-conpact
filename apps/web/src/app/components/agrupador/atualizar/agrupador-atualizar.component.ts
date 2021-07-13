import { UtilService } from './../../../services/util.service';
import { Agrupador } from '@admin/domain';
import { Component, OnInit } from '@angular/core';
import { FormBuilder, Validators } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { MensagemService } from '../../../services/shared/mensagem.service';
import { CrudFormComponent } from '../../shared/crud/list/crud.form.component';
import { RemoteService } from './../../../services/shared/remote.service';

@Component({
  selector: 'app-agrupador-atualizar',
  templateUrl: './agrupador-atualizar.component.html',
  styleUrls: ['./agrupador-atualizar.component.css']
})
export class AgrupadorAtualizarComponent extends CrudFormComponent<Agrupador> implements OnInit {

  constructor(
    protected readonly service: RemoteService,
    protected router: Router,
    protected route: ActivatedRoute,
    private formBuilder: FormBuilder,
    private util: UtilService,
    protected mensagem: MensagemService,) {
      super(service, mensagem,  router, route);
      this.resource = "agrupador";
  }

  criarForm() {
    this.formulario = this.formBuilder.group({
      descricao: ['', Validators.required],
      codigoCadastroUnico: [this.util.getCodigoCadastroUnicoLogado()]
    })
  }
}
