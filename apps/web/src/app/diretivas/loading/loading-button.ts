import { Directive, ElementRef, EventEmitter, HostListener, Input, Renderer2 } from '@angular/core';
import { Subscription } from 'rxjs';

@Directive({
  selector: '[loading]'
})
export class LoadingButton {

  @Input('loading') carregando: EventEmitter<boolean>;
  subscription: Subscription;

  constructor(
    private renderer: Renderer2,
    private el: ElementRef
  ) {}

  @HostListener('click')
  onClick() {
    this.renderer.setAttribute(this.el.nativeElement, 'disabled', 'true');

    let icon = this.renderer.createElement("img");
    this.renderer.setAttribute(icon, "src", "../../../assets/img/1495.gif");
    this.renderer.setAttribute(icon, "style", "width: 20px; height: 20px");
    this.renderer.appendChild(this.el.nativeElement, icon);
  }

  ngOnInit() {
    this.subscription = this.carregando.subscribe(value => {
      if(!value) {
        this.renderer.removeAttribute(this.el.nativeElement, 'disabled');

        for (let index = 0; index < this.el.nativeElement.children.length; index++) {
          const element = this.el.nativeElement.children[index];

          if(element.localName == 'img') {
            this.renderer.removeChild(this.el.nativeElement, element)
          }

        }
      }
    });
  }

  ngOnDestroy() {
    this.subscription && this.subscription.unsubscribe();
  }

}
