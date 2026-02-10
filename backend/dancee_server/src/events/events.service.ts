import { Injectable, NotFoundException } from '@nestjs/common';
import { EventRepository } from './repositories/event.repository';
import { FavoritesRepository } from './repositories/favorites.repository';
import { EventDto } from './dto/event.dto';

/**
 * Service layer for managing dance events.
 * This is a direct port from the Dart dancee_event_service.
 */
@Injectable()
export class EventsService {
  constructor(
    private readonly eventRepository: EventRepository,
    private readonly favoritesRepository: FavoritesRepository,
  ) {}

  /**
   * Retrieves all available dance events.
   * If userId is provided, marks events as favorite if they are in user's favorites.
   */
  async getAllEvents(userId?: string): Promise<EventDto[]> {
    const events = await this.eventRepository.getAllEvents();

    // If no userId provided, return events as-is
    if (!userId) {
      return events;
    }

    // Get user's favorite event IDs
    const favorites = await this.favoritesRepository.getFavorites(userId);
    const favoriteIds = new Set(favorites.map((e) => e.id));

    // Mark events as favorite if they are in user's favorites
    return events.map((event) => ({
      ...event,
      isFavorite: favoriteIds.has(event.id),
    }));
  }

  /**
   * Retrieves all favorite events for a given user.
   */
  async getFavorites(userId: string): Promise<EventDto[]> {
    return this.favoritesRepository.getFavorites(userId);
  }

  /**
   * Adds an event to a user's favorites.
   * Validates that the event exists before adding.
   */
  async addFavorite(userId: string, eventId: string): Promise<void> {
    const event = await this.eventRepository.getEventById(eventId);

    if (!event) {
      throw new NotFoundException('Event not found');
    }

    // Mark event as favorite before storing
    const favoriteEvent = { ...event, isFavorite: true };
    await this.favoritesRepository.addFavorite(userId, favoriteEvent);
  }

  /**
   * Removes an event from a user's favorites.
   * Validates that the event exists before removing.
   */
  async removeFavorite(userId: string, eventId: string): Promise<void> {
    const eventExists = await this.eventRepository.eventExists(eventId);

    if (!eventExists) {
      throw new NotFoundException('Event not found');
    }

    await this.favoritesRepository.removeFavorite(userId, eventId);
  }
}
