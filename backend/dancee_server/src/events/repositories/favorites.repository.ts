import { Injectable, Logger } from '@nestjs/common';
import { EventDto } from '../dto/event.dto';
import { FirebaseService } from '../../firebase/firebase.service';

/**
 * Repository for managing user favorites using Firestore.
 * This is a direct port from the Dart dancee_event_service.
 */
@Injectable()
export class FavoritesRepository {
  private readonly logger = new Logger(FavoritesRepository.name);
  private readonly collectionName = 'favorites';

  constructor(private readonly firebaseService: FirebaseService) {}

  /**
   * Returns all favorite events for a given user.
   */
  async getFavorites(userId: string): Promise<EventDto[]> {
    try {
      const firestore = this.firebaseService.getFirestore();
      const snapshot = await firestore
        .collection(this.collectionName)
        .doc(userId)
        .collection('events')
        .get();

      return snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      })) as EventDto[];
    } catch (error) {
      this.logger.error(`Failed to get favorites for user: ${userId}`, error);
      throw error;
    }
  }

  /**
   * Adds an event to a user's favorites (idempotent operation).
   */
  async addFavorite(userId: string, event: EventDto): Promise<void> {
    try {
      const firestore = this.firebaseService.getFirestore();
      const { id, ...eventData } = event;

      await firestore
        .collection(this.collectionName)
        .doc(userId)
        .collection('events')
        .doc(id)
        .set(eventData);

      this.logger.log(`Added favorite for user ${userId}: ${id}`);
    } catch (error) {
      this.logger.error(
        `Failed to add favorite for user ${userId}: ${event.id}`,
        error,
      );
      throw error;
    }
  }

  /**
   * Removes an event from a user's favorites (idempotent operation).
   */
  async removeFavorite(userId: string, eventId: string): Promise<void> {
    try {
      const firestore = this.firebaseService.getFirestore();
      await firestore
        .collection(this.collectionName)
        .doc(userId)
        .collection('events')
        .doc(eventId)
        .delete();

      this.logger.log(`Removed favorite for user ${userId}: ${eventId}`);
    } catch (error) {
      this.logger.error(
        `Failed to remove favorite for user ${userId}: ${eventId}`,
        error,
      );
      throw error;
    }
  }
}
