import { Module, NestModule, MiddlewareConsumer } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ScraperModule } from './scraper/scraper.module';
import { EventsModule } from './events/events.module';
import { SwaggerAuthMiddleware } from './middleware/swagger-auth.middleware';

@Module({
  imports: [ScraperModule, EventsModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    // Apply authentication middleware to all routes
    // The middleware itself will check the path and only protect Swagger routes
    consumer.apply(SwaggerAuthMiddleware).forRoutes('*');
  }
}
