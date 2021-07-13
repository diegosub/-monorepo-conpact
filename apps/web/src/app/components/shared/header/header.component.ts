import { UtilService } from './../../../services/util.service';
import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { MatDialogConfig, MatDialog } from '@angular/material/dialog';

@Component({
  selector: 'app-header',
  templateUrl: './header.component.html',
  styleUrls: ['./header.component.css']
})
export class HeaderComponent implements OnInit
{
  constructor(private router: Router,
              public dialog: MatDialog,
              private util: UtilService){}

  ngOnInit(){}

  perfil()
  {
    this.router.navigate(['/perfil'])
  }

  alterarSenha()
  {
    const dialogConfig = new MatDialogConfig();
    dialogConfig.width = '30%';

    // this.dialog.open(AlterarSenhaComponent, dialogConfig)
    //            .afterClosed().subscribe(() => {

    // });
  }

  logout()
  {
    this.util.setLogout();
  }
}
