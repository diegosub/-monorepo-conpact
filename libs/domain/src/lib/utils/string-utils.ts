export namespace StringUtils {

  export function isParentNode(index: number, str: string): boolean {
    return isElementFirst(index) || !existsStr(str);
  }

  export function getParentNode(index: number, str: string, strNext: string): string {
    return isElementFirst(index) ? str : existsStr(strNext) ? strNext : null;
  }

  export function isElementFirst(index: number): boolean {
    return index === 0;
  }

  export function existsStr(str: string): boolean {
    return str !== "" && str !== null;
  }
}
