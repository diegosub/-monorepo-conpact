import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { MensagemService } from '../../../services/shared/mensagem.service';
import { RemoteService } from '../../../services/shared/remote.service';
import { FormComponent } from '../../shared/form/form.component';
import { AuthService } from './../../../services/auth/auth.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent extends FormComponent implements OnInit {

  userAuthentication: any;

  constructor(
    private authService: AuthService,
    private formBuilder: FormBuilder,
    protected route: ActivatedRoute,
    protected readonly service: RemoteService) {
    super(route, service);
  }

  ngOnInit() {
    this.createForm();
  }

  createForm() {
    this.formulario = this.formBuilder.group({
      username: ['', Validators.required],
      password: ['', Validators.required]
    });
  }

  submit() {
      this.authService.login(this.formulario.value).subscribe(
        (data: any)=> {
          localStorage.setItem("adminUsr", JSON.stringify(data));
          location.href = '/';
        }
      )
  }
}
