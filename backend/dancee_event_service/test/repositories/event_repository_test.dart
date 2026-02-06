import 'package:test/test.dart';
import 'package:dancee_event_service/repositories/event_repository.dart';

void main() {
  group('EventRepository', () {
    late EventRepository repository;

    setUp(() {
      repository = EventRepository();
    });

    test('initializes with sample events', () async {
      final events = await repository.getAllEvents();
      expect(events, isNotEmpty);
      expect(events.length, greaterThanOrEqualTo(5));
    });

    test('getAllEvents returns all events', () async {
      final events = await repository.getAllEvents();
      expect(events, isList);
      // Verify first event has required fields
      expect(events.first.id, isNotEmpty);
      expect(events.first.title, isNotEmpty);
      expect(events.first.organizer, isNotEmpty);
    });

    test('eventExists returns true for existing event', () async {
      final events = await repository.getAllEvents();
      final firstEventId = events.first.id;
      
      final exists = await repository.eventExists(firstEventId);
      expect(exists, isTrue);
    });

    test('eventExists returns false for non-existent event', () async {
      final exists = await repository.eventExists('non-existent-id');
      expect(exists, isFalse);
    });

    test('getEventById returns correct event', () async {
      final events = await repository.getAllEvents();
      final firstEvent = events.first;
      
      final retrievedEvent = await repository.getEventById(firstEvent.id);
      expect(retrievedEvent, isNotNull);
      expect(retrievedEvent!.id, equals(firstEvent.id));
      expect(retrievedEvent.title, equals(firstEvent.title));
    });

    test('getEventById returns null for non-existent event', () async {
      final event = await repository.getEventById('non-existent-id');
      expect(event, isNull);
    });

    test('sample events have complete data', () async {
      final events = await repository.getAllEvents();
      
      for (final event in events) {
        // Verify required fields
        expect(event.id, isNotEmpty);
        expect(event.title, isNotEmpty);
        expect(event.description, isNotEmpty);
        expect(event.organizer, isNotEmpty);
        
        // Verify venue
        expect(event.venue.name, isNotEmpty);
        expect(event.venue.address.street, isNotEmpty);
        expect(event.venue.address.city, isNotEmpty);
        expect(event.venue.address.postalCode, isNotEmpty);
        expect(event.venue.address.country, isNotEmpty);
        
        // Verify timing
        expect(event.startTime, isNotNull);
        expect(event.endTime, isNotNull);
        expect(event.duration, isNotNull);
        
        // Verify dances
        expect(event.dances, isNotEmpty);
        
        // Verify parts
        expect(event.parts, isNotEmpty);
      }
    });
  });
}
