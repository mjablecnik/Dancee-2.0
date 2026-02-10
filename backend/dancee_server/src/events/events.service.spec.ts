import { Test, TestingModule } from '@nestjs/testing';
import { EventsService } from './events.service';
import { EventRepository } from './repositories/event.repository';
import { FavoritesRepository } from './repositories/favorites.repository';
import { NotFoundException } from '@nestjs/common';

describe('EventsService', () => {
  let service: EventsService;
  let eventRepository: EventRepository;
  let favoritesRepository: FavoritesRepository;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [EventsService, EventRepository, FavoritesRepository],
    }).compile();

    service = module.get<EventsService>(EventsService);
    eventRepository = module.get<EventRepository>(EventRepository);
    favoritesRepository = module.get<FavoritesRepository>(FavoritesRepository);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('getAllEvents', () => {
    it('should return all events without userId', async () => {
      const events = await service.getAllEvents();
      expect(Array.isArray(events)).toBe(true);
      expect(events.length).toBe(8); // We have 8 sample events
    });

    it('should mark favorites when userId is provided', async () => {
      // Add a favorite
      await service.addFavorite('testuser', 'event-001');
      
      // Get all events with userId
      const events = await service.getAllEvents('testuser');
      const favoriteEvent = events.find(e => e.id === 'event-001');
      const nonFavoriteEvent = events.find(e => e.id === 'event-002');
      
      expect(favoriteEvent?.isFavorite).toBe(true);
      expect(nonFavoriteEvent?.isFavorite).toBe(false);
    });
  });

  describe('getFavorites', () => {
    it('should return empty array for user with no favorites', async () => {
      const favorites = await service.getFavorites('newuser');
      expect(favorites).toEqual([]);
    });

    it('should return user favorites', async () => {
      await service.addFavorite('testuser', 'event-001');
      await service.addFavorite('testuser', 'event-002');
      
      const favorites = await service.getFavorites('testuser');
      expect(favorites.length).toBe(2);
      expect(favorites.every(e => e.isFavorite)).toBe(true);
    });
  });

  describe('addFavorite', () => {
    it('should add event to favorites', async () => {
      await service.addFavorite('testuser', 'event-001');
      
      const favorites = await service.getFavorites('testuser');
      expect(favorites.length).toBe(1);
      expect(favorites[0].id).toBe('event-001');
      expect(favorites[0].isFavorite).toBe(true);
    });

    it('should throw NotFoundException for invalid eventId', async () => {
      await expect(
        service.addFavorite('testuser', 'invalid-event'),
      ).rejects.toThrow(NotFoundException);
    });

    it('should be idempotent (adding same favorite twice)', async () => {
      await service.addFavorite('testuser', 'event-001');
      await service.addFavorite('testuser', 'event-001');
      
      const favorites = await service.getFavorites('testuser');
      expect(favorites.length).toBe(1);
    });
  });

  describe('removeFavorite', () => {
    it('should remove event from favorites', async () => {
      // Add favorite
      await service.addFavorite('testuser', 'event-001');
      
      // Verify it exists
      let favorites = await service.getFavorites('testuser');
      expect(favorites.length).toBe(1);
      
      // Remove it
      await service.removeFavorite('testuser', 'event-001');
      
      // Verify it's gone
      favorites = await service.getFavorites('testuser');
      expect(favorites.length).toBe(0);
    });

    it('should throw NotFoundException for invalid eventId', async () => {
      await expect(
        service.removeFavorite('testuser', 'invalid-event'),
      ).rejects.toThrow(NotFoundException);
    });

    it('should be idempotent (removing non-existent favorite)', async () => {
      // Should not throw error
      await expect(
        service.removeFavorite('testuser', 'event-001'),
      ).resolves.not.toThrow();
    });
  });
});
