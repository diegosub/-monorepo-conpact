import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { UtilLoader } from '../util/util-loader';

@Component({
  selector: 'app-menu',
  templateUrl: './menu.component.html',
  styleUrls: ['./menu.component.css']
})
export class MenuComponent implements OnInit {

  nome: String;
  email: String;
  nomeFormatado: String;
  foto: String;

  arrayNome = [];

  constructor(public router: Router){}

  ngOnInit()
  {
    //this.email = JSON.parse(localStorage.getItem('adminUsr')).email;
    this.nome = JSON.parse(localStorage.getItem('adminUsr')).nome;
    this.arrayNome = this.nome.split(" ");

    this.nomeFormatado = "";
    if(this.arrayNome[0] != undefined) {this.nomeFormatado += this.arrayNome[0]}
    if(this.arrayNome[1] != undefined) {this.nomeFormatado += " "+this.arrayNome[1]}

    this.foto = JSON.parse(localStorage.getItem('adminUsr')).fotoUsuario;
  }


  logout()
  {
    localStorage.removeItem("adminUsr");
    this.router.navigate(['/login']);
  }

}
