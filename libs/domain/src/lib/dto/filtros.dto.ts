export interface FiltrosDTO {
  value?: any;
  sortDirection?: string;
  sortActive?: string;
  pageNumber?: number;
  pageSize?: number;
}

export function filtrosToString(filtrosDTO: FiltrosDTO): string {
  return JSON.stringify(filtrosDTO);
}

export function stringToFiltros(strJson: string): any {
  if(strJson) {
    return JSON.parse(strJson);
  }
}

export function buildFiltros(stringFiltros: string, req?: any): FiltrosDTO {
  const filtrosJson = stringToFiltros(stringFiltros);
  if (req) {
    filtrosJson['value']['usuario'] = req['user']['_id']
  }
  return filtrosJson;
}
