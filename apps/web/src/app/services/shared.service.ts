import { Injectable, EventEmitter } from '@angular/core';

@Injectable()
export class SharedService {

  public static instance: SharedService = null;

  constructor() {
    return SharedService.instance = SharedService.instance || this;
  }

  public static getInstance(){
    if(this.instance == null){
      this.instance = new SharedService();
    }
    return this.instance;
  }

  isLoggedIn():boolean {
    alert("chegou");
    if(localStorage.getItem("usuario") == null){
      return false;
    } else {
      return true;
    }
  }

}
