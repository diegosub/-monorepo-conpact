import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { AptEmailComponent } from './apt-email.component';

describe('AptEmailComponent', () => {
  let component: AptEmailComponent;
  let fixture: ComponentFixture<AptEmailComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ AptEmailComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(AptEmailComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
