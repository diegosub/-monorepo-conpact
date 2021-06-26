import { DateUtils } from '@admin/domain';
import * as mongoose from 'mongoose';
import * as _ from 'lodash';

export class QueryHelper {

  filters = {};
  sort = {}

  idEqual(field: string, id: string): QueryHelper {
    if(id != null && id != undefined) {
      this.filters[field] = mongoose.Types.ObjectId(id);
    }
    return this;
  }

  like(field: string, value: string): QueryHelper {
    if(value != null && value != undefined) {
      let regexValue = value.replace(/\./g, '\\.');
      regexValue = regexValue.trim().replace(/ /g, ' +');
      this.filters[field] = new RegExp(`.*${regexValue}.*`, 'i');
    }
    return this;
  }

  equal(field: string, value: string): QueryHelper {
    if(value != null && value != undefined) {
      this.filters[field] = new RegExp(`^${value.replace(/\./g, '\\.').trim()}$`, 'i');
    }
    return this;
  }

  rawEqual(field: string, value: any): QueryHelper {
    if(value != null && value != undefined) {
      this.filters[field] = value;
    }
    return this;
  }

  notEqual(field: string, value: any): QueryHelper {
    if(value != null && value != undefined) {
      this.filters[field] = { "$ne": value };
    }
    return this;
  }

  in(field: string, value: any[]): QueryHelper {
    if(value != null && value != undefined) {
      this.filters[field] = { "$in": value };
    }
    return this;
  }

  inFromObject(field: string, value: any[]): QueryHelper {
    if(value != null && value != undefined) {
      const keys = _.map(value, field);
      return this.in(field, keys);
    } else {
      return this;
    }
  }

  idIn(field: string, value: any[]): QueryHelper {
    if(value != null && value != undefined) {
      const keys = _.map(value, field);
      const objectsAdd = [];
      for (let i = 0; i < keys.length; i++) {
        objectsAdd.push(mongoose.Types.ObjectId(keys[i]));
      }
      return this.in(field, objectsAdd);
    } else {
      return this;
    }
  }

  exists(field: string, value: any): QueryHelper {
    if(value != null && value != undefined) {
      this.filters[field] = { "$exists": value };
    }
    return this;
  }

  dataGte(field: string, data: Date): void {
    if(data != null && data != undefined) {
      const d1 = DateUtils.formatDate(data);
      this.filters[field] = { $gte: new Date(d1) };
    }
  }

  dataLte(field: string, data: Date): void {
    if(data != null && data != undefined) {
      const d1 = DateUtils.formatDate(data);
      this.filters[field] = { $lte: new Date(d1) };
    }
  }

  datasBetween(field: string, dataInicial: Date, dataFinal: Date): void {
    if(dataInicial != null && dataFinal != undefined) {
      const d1 = DateUtils.formatDate(dataInicial);
      const d2 = DateUtils.formatDate(dataFinal);
      this.filters[field] = { $gte: new Date(d1), $lte: new Date(d2) };
    }
  }

  notIn(field: string, value: any[]): QueryHelper {
    if(value != null && value != undefined) {
      this.filters[field] = { "$nin": value };
    }
    return this;
  }

  setOrder(field: string, order: string): QueryHelper {
    if(order != null && order != undefined) {
      this.sort[field] = this.getSortType(order);
    }
    return this;
  }

  getSortType(order: string): number {
    switch (order.toLowerCase()) {
      case 'asc': return 1
      case 'desc': return -1
      default: return 1
    }
  }
}
