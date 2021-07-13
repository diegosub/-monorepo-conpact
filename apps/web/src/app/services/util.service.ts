import { Injectable } from '@angular/core';
import { Router } from '@angular/router';



@Injectable({
  providedIn: 'root'
})
export class UtilService
{
  private loading: number = 0;
  public static enableToken: boolean = true;

  constructor(private router: Router) {}

  isLoggedIn():boolean
  {
    if(localStorage.getItem("adminUsr") == null)
    {
      return false;
    }
    else
    {
      return true;
    }
  }

  refreshToken()
  {

  }

  setLogout()
  {
    localStorage.removeItem("adminUsr");
    this.router.navigate(['/login']);
  }

  validarCampo(campo, alias)
  {
    if(typeof campo === 'undefined' || campo == null || campo.toString() == '')
    {
      throw new Error("O campo " + alias + " é obrigatório.");
    }
  }

  compare(a: number | string | Date | boolean, b: number | string | Date | boolean, isAsc: boolean)
  {
    return (a < b ? -1 : 1) * (isAsc ? 1 : -1);
  }

  inicioPaginaPesquisa(route)
  {
    let objFiltro = localStorage.getItem("objFiltro");

    if(objFiltro != null
        && typeof objFiltro != 'undefined')
    {
        return JSON.parse(objFiltro);
    }
    else
    {
        return null;
    }
  }

  setarObjetoBack(objeto)
  {
    localStorage.setItem("objFiltro", JSON.stringify(objeto));
  }

  fimPaginaPesquisa()
  {
    localStorage.removeItem("objFiltro");
  }

  validarCpf(numeroCpf: any)
  {
    let retorno = true;

    if (numeroCpf == null || numeroCpf == '') {
      return true;
    }

    let reg1 = /\./gi;
    let reg2 = /\-/gi;
    let str1 = numeroCpf.replace(reg1,"");
    let cpf = str1.replace(reg2, "");

    if (cpf.length != 11)
    {
      retorno = false;
    }

    if ((cpf == '00000000000') || (cpf == '11111111111') || (cpf == '22222222222') || (cpf == '33333333333') || (cpf == '44444444444') || (cpf == '55555555555') || (cpf == '66666666666') || (cpf == '77777777777') || (cpf == '88888888888') || (cpf == '99999999999'))
    {
      retorno = false;
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
            retorno = false;
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
      retorno = false;
    }

    return retorno;
  }

  validarEmail(stringEmail)
  {
    let email = stringEmail;

    if(email == null || email == '') {
      return true;
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
      return false;
    }
  }

  somarHoras(hora1, minutosAdicionar)
  {
    let varMinutosInicio = (parseInt(hora1.substring(0,2)) * 60) + (parseInt(hora1.substring(3,5)));
    let varMinutosAdicionar = minutosAdicionar;

    let minutosFinal = varMinutosInicio + varMinutosAdicionar;

    let horas = 0;
    let minutos = 0;

    if(minutosFinal > minutosFinal / 60)
    {
      horas   = Math.floor(minutosFinal / 60);
      minutos = minutosFinal - horas*60;
    }
    else
    {
      horas = 0;
      minutos = minutosFinal;
    }

    let hr: string = horas+"";
    let mn: string = minutos+"";

    hr = hr.length < 2 ? "0"+hr : hr;
    mn = mn.length < 2 ? "0"+mn : mn;

    return hr+":"+mn;
  }

  getUsuarioLogado()
  {
    return JSON.parse(localStorage.getItem("adminUsr"));
  }

  getCodigoUsuarioLogado()
  {
    return this.getUsuarioLogado().codigo;
  }

  getCodigoCadastroUnicoLogado()
  {
    console.log(this.getUsuarioLogado())
    return this.getUsuarioLogado().codigoCadastroUnico;
  }
}
