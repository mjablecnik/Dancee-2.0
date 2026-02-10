import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
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
