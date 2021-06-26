
export interface Adapter<K, T> {

  adapt(data: K): T;
}
