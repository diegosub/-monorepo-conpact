export class DataSetPage<T> {

  data: T[];
  size = 0;

  constructor(data?: T[], size?: number){
    if(data){
      this.data = data;
    }
    if(size){
      this.size = size;
    }
  }
}
