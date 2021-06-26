import { TimeStamps } from '@typegoose/typegoose/lib/defaultClasses';

export abstract class BaseSchema extends TimeStamps {

  _id: string;
  createdAt: Date;
  updatedAt: Date;

}
