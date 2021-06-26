export namespace PuppeteerUtils {

  export async function _sleep() {
    await this._sleepByTime(4000);
  }

  export async function _sleepByTime(time: number) {
    await this.sleep(time);
  }

  export async function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}
