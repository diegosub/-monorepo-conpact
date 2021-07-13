import { Directive, ElementRef, HostListener } from '@angular/core';

@Directive({
  selector: '[soNumero]'
})
export class SoNumero
{
  constructor(private element: ElementRef)
  {
    this.element.nativeElement.value = this.element.nativeElement.value.replace(/\D/g,"");
  }

  @HostListener('keydown')
  keyDown()
  {
    this.element.nativeElement.value = this.element.nativeElement.value.replace(/\D/g,"");
  }

  @HostListener('keyup')
  keyUp()
  {
    this.element.nativeElement.value = this.element.nativeElement.value.replace(/\D/g,"");
  }

  @HostListener('keypress')
  keyPress()
  {
    this.element.nativeElement.value = this.element.nativeElement.value.replace(/\D/g,"");
  }  

  @HostListener('blur')
  blur() 
  { 
    this.element.nativeElement.value = this.element.nativeElement.value.replace(/\D/g,"");
  }

}