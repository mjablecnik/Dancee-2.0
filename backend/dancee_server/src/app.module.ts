import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ScraperModule } from './scraper/scraper.module';
import { EventsModule } from './events/events.module';
import { FirebaseModule } from './firebase/firebase.module';

@Module({
  imports: [FirebaseModule, ScraperModule, EventsModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
