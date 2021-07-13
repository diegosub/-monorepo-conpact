import { CommonModule } from '@angular/common';
import { HttpClientModule, HTTP_INTERCEPTORS } from '@angular/common/http';
import { CUSTOM_ELEMENTS_SCHEMA, ErrorHandler, NgModule } from '@angular/core';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { DateAdapter, MatNativeDateModule, MAT_DATE_LOCALE } from '@angular/material/core';
import { MatDatepickerModule } from '@angular/material/datepicker';
import { MatDialogModule } from '@angular/material/dialog';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatTooltipModule } from '@angular/material/tooltip';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { NgxMaskModule } from 'ngx-mask';
import { PerfectScrollbarConfigInterface, PerfectScrollbarModule, PERFECT_SCROLLBAR_CONFIG } from 'ngx-perfect-scrollbar';
import { NgProgressModule } from 'ngx-progressbar';
import { ToastrModule } from 'ngx-toastr';
import { environment } from '../environments/environment';
import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { HomeComponent } from './components/home/home.component';
import { AuthInterceptor } from './components/security/auth.interceptor';
import { LoginComponent } from './components/security/login/login.component';
import { FooterComponent } from './components/shared/footer/footer.component';
import { HeaderComponent } from './components/shared/header/header.component';
import { MenuComponent } from './components/shared/menu/menu.component';
import { NotfoundComponent } from './components/shared/notfound/notfound.component';
import { SharedModule } from './components/shared/shared.module';
import { TemplateComponent } from './components/shared/template/template.component';
import { DateFormat } from './components/shared/util/date-format';
import { ENVIRONMENT } from './services/environment.service';
import { GlobalErrorHandler } from './services/error/global.error.handler';

const DEFAULT_PERFECT_SCROLLBAR_CONFIG: PerfectScrollbarConfigInterface = {
  suppressScrollX: true
};

@NgModule({
  declarations: [
    AppComponent,
    NotfoundComponent,
    HeaderComponent,
    FooterComponent,
    MenuComponent,
    HomeComponent,
    LoginComponent,
    TemplateComponent
  ],
  imports: [
    PerfectScrollbarModule,
    BrowserModule,
    AppRoutingModule,
    BrowserAnimationsModule,
    CommonModule,
    FormsModule,
    ReactiveFormsModule,
    MatDatepickerModule,
    MatNativeDateModule,
    MatToolbarModule,
    MatDialogModule,
    MatTooltipModule,
    HttpClientModule,
    NgxMaskModule.forRoot(),

    SharedModule,

    ToastrModule.forRoot(),
    NgProgressModule.withConfig({
      spinner: false,
      color: "orangered"
    }),
  ],
  providers: [
    { provide: ENVIRONMENT, useValue: environment },
    { provide: HTTP_INTERCEPTORS, useClass: AuthInterceptor, multi: true },
    { provide: PERFECT_SCROLLBAR_CONFIG, useValue: DEFAULT_PERFECT_SCROLLBAR_CONFIG },
    { provide: MAT_DATE_LOCALE, useValue: 'pt-BR'},
    { provide: DateAdapter, useClass: DateFormat },
    { provide: ErrorHandler, useClass: GlobalErrorHandler },
  ],
  bootstrap: [AppComponent],
  schemas: [CUSTOM_ELEMENTS_SCHEMA]
})
export class AppModule { }
