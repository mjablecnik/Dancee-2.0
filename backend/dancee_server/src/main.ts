import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';

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
  await app.listen(port);

  console.log(`🚀 Dancee Server is running on: http://localhost:${port}`);
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
