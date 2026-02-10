import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';
const basicAuth = require('express-basic-auth');

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Enable global validation
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  // Enable CORS for frontend communication
  app.enableCors({
    origin: true, // Allow all origins in development
    credentials: true,
  });

  // Basic Auth
  if (process.env.NODE_ENV === 'production') {
    app.use(['api', '/api', '/api-json'], basicAuth({
      challenge: true,
      users: {
        admin: 'test123',  // => username: admin, password: heslo123
      },
    }));
  }

  // Swagger API Documentation
  const config = new DocumentBuilder()
    .setTitle('Dancee Server API')
    .setDescription('Facebook Event Scraper API for Dancee App')
    .setVersion('1.0.0')
    .addTag('scraper', 'Facebook event scraping endpoints')
    .addTag('app', 'Application health and info endpoints')
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api', app, document);

  const port = process.env.PORT ?? 3001;
  const host = process.env.HOST ?? '0.0.0.0';
  await app.listen(port, host);

  console.log(`🚀 Dancee Server is running on: http://${host}:${port}`);
  console.log(
    `📚 Swagger documentation available at: http://localhost:${port}/api`,
  );

  if (process.env.NODE_ENV === 'production') {
    console.log(
      `🔒 Swagger is protected with Basic Authentication in production`,
    );
  }
}
bootstrap();
