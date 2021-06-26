import { NestFactory } from '@nestjs/core';
import * as compression from 'compression';
import * as helmet from 'helmet';
import { urlencoded, json } from 'express';
import { ConfigService } from '@nestjs/config';
import { AppModule } from './app.module';
import { LoggingInterceptor, ExceptionsFilter } from '@admin/core';

async function bootstrap() {

  const app = await NestFactory.create(AppModule);

  const configService = app.get(ConfigService);
  const loggingInterceptor = app.get(LoggingInterceptor);
  const exceptionsFilter = app.get(ExceptionsFilter);

  app.setGlobalPrefix(configService.get('API_GLOBAL_PREFIX'));
  app.use(helmet());
  app.use(compression());
  app.enableCors();
  app.use(json({ limit: '50mb' }));
  app.use(urlencoded({ extended: true, limit: '50mb' }));

  const requestLog = configService.get('REQUEST_LOG');
  if (requestLog && requestLog === 'true') {
    app.useGlobalInterceptors(loggingInterceptor);
  }

  app.useGlobalFilters(exceptionsFilter);
  await app.listen(configService.get('SERVER_PORT'));
}

(async () => {

  await bootstrap();

})();
