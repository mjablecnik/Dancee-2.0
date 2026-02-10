import { Module } from '@nestjs/common';
import { EventsController } from './events.controller';
import { EventsService } from './events.service';
import { EventRepository } from './repositories/event.repository';
import { FavoritesRepository } from './repositories/favorites.repository';

@Module({
  controllers: [EventsController],
  providers: [EventsService, EventRepository, FavoritesRepository],
  exports: [EventsService],
})
export class EventsModule {}
