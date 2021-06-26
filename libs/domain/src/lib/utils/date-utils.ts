import * as moment from 'moment-timezone';

export namespace DateUtils {
  const DATE_TEXT_PATTERN = 'DD/MM/YYYY';
  const DATE_TEXT_PATTERN_HOUR_MINUTE = 'DD/MM/YYYY HH:mm';

  export enum Periodos {
    HOJE = 'HOJE',
    SEMANA_ATUAL = 'SEMANA_ATUAL',
    ULTIMOS_SETE_DIAS = 'ULTIMOS_SETE_DIAS',
    ULTIMOS_QUINZE_DIAS = 'ULTIMOS_QUINZE_DIAS',
    ULTIMOS_TRINTA_DIAS = 'ULTIMOS_TRINTA_DIAS',
    MES_ATUAL = 'MES_ATUAL',
    INTERVALO = 'INTERVALO'
  }

  // 'YYYY-MM-DDTHH:mm:ss[Z]'
  export class DateUtcStr {
    dateUtcStr: string;

    constructor(dateUtcStr: string) {
      this.dateUtcStr = dateUtcStr;
    }

    private extractPart(start: number, length?: number): string {
      return this.dateUtcStr.substr(start, length);
    }

    get year(): string {
      return this.extractPart(0, 4);
    }

    get month(): string {
      return this.extractPart(5, 2);
    }

    get hour(): string {
      return this.extractPart(11, 2);
    }

    get minute(): string {
      return this.extractPart(14, 2);
    }

    get second(): string {
      return this.extractPart(17, 2);
    }

    get day(): string {
      return this.extractPart(8, 2);
    }
  }

  export function strToPeriodo(periodo: string): Periodos {
    return Periodos[periodo];
  }

  export function formatPeriodoToStr(periodo: string): string {
    const periodos = strToPeriodo(periodo);
    const datas = extractDatasPeriodo(periodos, '');
    const dataInicialStr = formatDate(datas.dataInicial, DATE_TEXT_PATTERN);
    const dataFinalStr = formatDate(datas.dataFinal, DATE_TEXT_PATTERN);
    return `${dataInicialStr} - ${dataFinalStr}`;
  }

  export function parseDateMask(inputDateValue: any | string): Date {
    if (inputDateValue instanceof Date || inputDateValue.indexOf('/') === -1) {
      return new Date(inputDateValue);
    } else {
      return parseDatePtBr(inputDateValue);
    }
  }

  export function now(): Date {
    return momentUTC().toDate();
  }

  export function isValid(date: Date) {
    return moment(date).isValid();
  }

  export function dateDiff(date1: Date, date2: Date, medida: any): number {
    return momentUTC(date2).diff(momentUTC(date1), medida);
  }

  export function nowToStr(): string {
    return formatDate(now(), DATE_TEXT_PATTERN);
  }

  export function isNowAfterDateStr(date: string): boolean {
    return moment(nowToStr()).isAfter(date);
  }

  export function startDayOfYearToStr(): string {
    return moment().startOf('year').format('DD/MM/YYYY');
  }

  export function yesterdayToStr(): string {
    return formatDate(somar(-1, 'days'), DATE_TEXT_PATTERN);
  }

  export function getDatasIntervaloPeriodo(
    periodo: string,
    intervalo: string
  ): object {
    const periodos = strToPeriodo(periodo);
    return extractDatasPeriodo(periodos, intervalo);
  }

  export function momentUTC(date?: Date | string): moment.Moment {
    const _moment = date ? moment(date).tz('UTC') : moment().tz('UTC');
    // return _moment.add(-3, "hours");
    return _moment;
  }

  export function formatDate(
    data: Date | string,
    pattern?: string,
    utc = false
  ): string {
    if (utc) {
      return momentUTC(data).format(pattern);
    }
    return moment(data).format(pattern);
  }

  export function parseDateTime(dataStr: string, pattern?: string): Date {
    if (!pattern) {
      pattern = 'YYYY-MM-DD HH:mm:ss';
    }
    return moment(dataStr, pattern).toDate();
  }

  export function getCurrentYear() {
    return new Date().getFullYear();
  }

  export function getCurrentHour() {
    return new Date().getHours();
  }

  export function parseDate(dataStr: string, pattern?: string): Date {
    if (!pattern) {
      pattern = 'YYYY-MM-DD';
    }
    return moment(dataStr, pattern).toDate();
  }

  export function parseDatePtBr(dataStr: string): Date {
    return moment(dataStr, 'DD/MM/YYYY').toDate();
  }

  export function getIntervaloData(data: string) {
    let dataInicial: Date;
    let dataFinal: Date;
    dataInicial = momentUTC(data)
      .startOf('day')
      .toDate();
    dataFinal = momentUTC(data)
      .endOf('day')
      .toDate();
    return {
      dataInicial: dataInicial,
      dataFinal: dataFinal
    };
  }

  export function somar(value: any, medida: any): Date {
    const agora = momentUTC();
    return agora.add(value, medida).toDate();
  }

  export function calcularVelocidadeMedia(espaco: number, tempo: number): number {
    const tempoKm = tempo / 60;
    return espaco / tempoKm;
  }

  export function extractDatasPeriodo(
    periodo: Periodos | string,
    intervalo?: string
  ): any {
    let dataInicial: Date;
    let dataFinal: Date;
    switch (periodo) {
      case Periodos.HOJE: {
        dataInicial = momentUTC()
          .startOf('day')
          .toDate();
        dataFinal = momentUTC()
          .endOf('day')
          .toDate();
        break;
      }
      case Periodos.SEMANA_ATUAL: {
        dataInicial = momentUTC()
          .startOf('week')
          .toDate();
        dataFinal = momentUTC()
          .endOf('week')
          .toDate();
        break;
      }
      case Periodos.ULTIMOS_SETE_DIAS: {
        dataInicial = momentUTC()
          .subtract(7, 'days')
          .startOf('day')
          .toDate();
        dataFinal = momentUTC()
          .subtract(1, 'days')
          .endOf('day')
          .toDate();
        break;
      }
      case Periodos.ULTIMOS_QUINZE_DIAS: {
        dataInicial = momentUTC()
          .subtract(15, 'days')
          .startOf('day')
          .toDate();
        dataFinal = momentUTC()
          .subtract(1, 'days')
          .endOf('day')
          .toDate();
        break;
      }
      case Periodos.ULTIMOS_TRINTA_DIAS: {
        dataInicial = momentUTC()
          .subtract(30, 'days')
          .startOf('day')
          .toDate();
        dataFinal = momentUTC()
          .subtract(1, 'days')
          .endOf('day')
          .toDate();
        break;
      }
      case Periodos.MES_ATUAL: {
        dataInicial = momentUTC()
          .startOf('month')
          .toDate();
        dataFinal = momentUTC()
          .endOf('month')
          .toDate();
        break;
      }
      case Periodos.INTERVALO: {
        const values = intervalo.split(' - ');
        dataInicial = moment(
          `${values[0]} 00:00:00`,
          'DD/MM/YYYY HH:mm:ss'
        ).toDate();
        dataFinal = moment(
          `${values[1]} 23:59:59`,
          'DD/MM/YYYY HH:mm:ss'
        ).toDate();
        break;
      }
    }
    return {
      dataInicial: dataInicial,
      dataFinal: dataFinal
    };
  }

  export function isBetween(compareDate: Date, startDate: Date, endDate: Date): boolean {
    const compareDateFormat = this.formatDate(compareDate, DATE_TEXT_PATTERN_HOUR_MINUTE);
    const startDateFormat = this.formatDate(startDate, DATE_TEXT_PATTERN_HOUR_MINUTE);
    const endDateFormat = this.formatDate(endDate, DATE_TEXT_PATTERN_HOUR_MINUTE);

    const isBetweenIn = compareDateFormat >= startDateFormat && compareDateFormat <= endDateFormat;
    return isBetweenIn;
  }

  export function minutesToDHM(minutes: number): string {
    const days = Math.floor(minutes / 1440);
    const hours = Math.floor(minutes / 60);
    const min = minutes % 60;
    let str = '';
    if(days > 0){
      str += (days > 1)? `${days} dias ` : `${days} dia `;
    }
    if(hours > 0){
      str += (hours > 1)? `${hours} horas ` : `${hours} hora`;
    }
    if(min > 0){
      str += `${min} min`;
    }
    return str;
  }
}
