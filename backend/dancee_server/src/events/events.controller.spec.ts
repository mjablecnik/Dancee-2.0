import { Test, TestingModule } from '@nestjs/testing';
import { EventsController } from './events.controller';
import { EventsService } from './events.service';
import { EventRepository } from './repositories/event.repository';
import { FavoritesRepository } from './repositories/favorites.repository';
import { BadRequestException, NotFoundException } from '@nestjs/common';

describe('EventsController', () => {
  let controller: EventsController;
  let service: EventsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [EventsController],
      providers: [EventsService, EventRepository, FavoritesRepository],
    }).compile();

    controller = module.get<EventsController>(EventsController);
    service = module.get<EventsService>(EventsService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('listEvents', () => {
    it('should return an array of events', async () => {
      const result = await controller.listEvents();
      expect(Array.isArray(result)).toBe(true);
      expect(result.length).toBeGreaterThan(0);
    });

    it('should mark favorites when userId is provided', async () => {
      // First add a favorite
      await service.addFavorite('user123', 'event-001');
      
      // Then list events with userId
      const result = await controller.listEvents('user123');
      const favoriteEvent = result.find(e => e.id === 'event-001');
      
      expect(favoriteEvent?.isFavorite).toBe(true);
    });
  });

  describe('listFavorites', () => {
    it('should throw BadRequestException when userId is missing', async () => {
      await expect(controller.listFavorites()).rejects.toThrow(BadRequestException);
    });

    it('should return empty array for user with no favorites', async () => {
      const result = await controller.listFavorites('newuser');
      expect(result).toEqual([]);
    });

    it('should return user favorites', async () => {
      await service.addFavorite('user123', 'event-001');
      const result = await controller.listFavorites('user123');
      
      expect(result.length).toBe(1);
      expect(result[0].id).toBe('event-001');
    });
  });

  describe('addFavorite', () => {
    it('should add event to favorites', async () => {
      const result = await controller.addFavorite({
        userId: 'user123',
        eventId: 'event-002',
      });

      expect(result.message).toBe('Favorite added successfully');
      expect(result.userId).toBe('user123');
      expect(result.eventId).toBe('event-002');
    });

    it('should throw NotFoundException for invalid eventId', async () => {
      await expect(
        controller.addFavorite({
          userId: 'user123',
          eventId: 'invalid-event',
        }),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe('removeFavorite', () => {
    it('should throw BadRequestException when userId is missing', async () => {
      await expect(
        controller.removeFavorite('event-001'),
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw NotFoundException for invalid eventId', async () => {
      await expect(
        controller.removeFavorite('invalid-event', 'user123'),
      ).rejects.toThrow(NotFoundException);
    });

    it('should remove event from favorites', async () => {
      // Add favorite first
      await service.addFavorite('user123', 'event-003');
      
      // Verify it was added
      let favorites = await service.getFavorites('user123');
      expect(favorites.some(e => e.id === 'event-003')).toBe(true);
      
      // Remove it
      await controller.removeFavorite('event-003', 'user123');
      
      // Verify it was removed
      favorites = await service.getFavorites('user123');
      expect(favorites.some(e => e.id === 'event-003')).toBe(false);
    });
  });
});
