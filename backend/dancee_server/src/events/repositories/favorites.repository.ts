import { Injectable } from '@nestjs/common';
import { EventDto } from '../dto/event.dto';

/**
 * Repository for managing user favorites using in-memory storage.
 * This is a direct port from the Dart dancee_event_service.
 */
@Injectable()
export class FavoritesRepository {
  private favorites: Map<string, EventDto[]> = new Map();

  /**
   * Returns all favorite events for a given user.
   */
  async getFavorites(userId: string): Promise<EventDto[]> {
    return [...(this.favorites.get(userId) || [])];
  }

  /**
   * Adds an event to a user's favorites (idempotent operation).
   */
  async addFavorite(userId: string, event: EventDto): Promise<void> {
    if (!this.favorites.has(userId)) {
      this.favorites.set(userId, []);
    }

    const userFavorites = this.favorites.get(userId)!;
    const alreadyExists = userFavorites.some((e) => e.id === event.id);

    if (!alreadyExists) {
      userFavorites.push(event);
    }
  }

  /**
   * Removes an event from a user's favorites (idempotent operation).
   */
  async removeFavorite(userId: string, eventId: string): Promise<void> {
    const userFavorites = this.favorites.get(userId);
    if (userFavorites) {
      const filtered = userFavorites.filter((event) => event.id !== eventId);
      this.favorites.set(userId, filtered);
    }
  }
}
