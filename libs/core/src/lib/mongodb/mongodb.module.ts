import { Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { TypegooseModule } from 'nestjs-typegoose';

@Module({
  imports: [
    TypegooseModule.forRootAsync({
      useFactory: async (configService: ConfigService) => ({
        uri: configService.get('MONGODB_URI'),
        useNewUrlParser: true,
        useUnifiedTopology: true,
        useCreateIndex: true,
        user: configService.get('MONGODB_USER'),
        password: configService.get('MONGODB_PASSWD'),
      }),
      inject: [ConfigService],
    }),
  ]
})
export class MongodbModule { }
