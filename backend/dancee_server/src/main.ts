import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
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

  const port = process.env.PORT ?? 3001;
  await app.listen(port);
  
  console.log(`🚀 Dancee Server is running on: http://localhost:${port}`);
}
bootstrap();
