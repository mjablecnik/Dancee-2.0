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
    // Apply authentication middleware to routes that might be Swagger-related
    // The middleware itself will check the exact path and only protect Swagger routes
    // while allowing /api/events, /api/favorites, etc. to pass through
    consumer
      .apply(SwaggerAuthMiddleware)
      .forRoutes('api', 'api/*path', 'api-json');
  }
}
