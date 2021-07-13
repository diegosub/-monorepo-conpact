import { FormValidations } from '../form/validator/form-validator';
import { Component, OnInit, Input } from '@angular/core';
import { FormControl } from '@angular/forms';

@Component({
  selector: 'app-msg-error',
  templateUrl: './msg-error.component.html',
  styleUrls: ['./msg-error.component.css']
})
export class MsgErrorComponent implements OnInit
{
  @Input() control: FormControl;
  @Input() label: string;

  constructor() { }

  ngOnInit() {
  }

  get errorMessage() {

    for (const propertyName in this.control.errors) {
      if (this.control.errors.hasOwnProperty(propertyName) &&  this.control.dirty && this.control.touched) {
          return FormValidations.getErrorMsg(this.label, propertyName, this.control.errors[propertyName]);
        }
    }

    return null;
  }


}
