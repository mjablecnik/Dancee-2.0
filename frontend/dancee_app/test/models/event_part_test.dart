import 'package:flutter_test/flutter_test.dart';
import 'package:dancee_app/models/event_part.dart';

void main() {
  group('EventPart', () {
    final startTime = DateTime(2024, 1, 15, 19, 30);
    final endTime = DateTime(2024, 1, 15, 21, 0);

    test('should create an EventPart with all required fields', () {
      final eventPart = EventPart(
        name: 'Sensual Styling Workshop',
        description: 'Learn sensual bachata styling techniques',
        type: EventPartType.workshop,
        startTime: startTime,
        endTime: endTime,
        lectors: ['Anna Martinez', 'Carlos Rodriguez'],
      );

      expect(eventPart.name, 'Sensual Styling Workshop');
      expect(eventPart.description, 'Learn sensual bachata styling techniques');
      expect(eventPart.type, EventPartType.workshop);
      expect(eventPart.startTime, startTime);
      expect(eventPart.endTime, endTime);
      expect(eventPart.lectors, ['Anna Martinez', 'Carlos Rodriguez']);
      expect(eventPart.djs, null);
    });

    test('should create EventPart with party type and DJs', () {
      final eventPart = EventPart(
        name: 'Social Dancing',
        description: 'Open social dancing with DJ',
        type: EventPartType.party,
        startTime: startTime,
        endTime: endTime,
        djs: ['DJ Carlos', 'DJ Maria'],
      );

      expect(eventPart.type, EventPartType.party);
      expect(eventPart.djs, ['DJ Carlos', 'DJ Maria']);
      expect(eventPart.lectors, null);
    });

    test('should create EventPart with openLesson type', () {
      final eventPart = EventPart(
        name: 'Beginner Salsa Lesson',
        type: EventPartType.openLesson,
        startTime: startTime,
        endTime: endTime,
        lectors: ['John Smith'],
      );

      expect(eventPart.type, EventPartType.openLesson);
      expect(eventPart.lectors, ['John Smith']);
    });

    test('should create EventPart without optional fields', () {
      final eventPart = EventPart(
        name: 'Social Dancing',
        type: EventPartType.party,
        startTime: startTime,
        endTime: endTime,
      );

      expect(eventPart.description, null);
      expect(eventPart.lectors, null);
      expect(eventPart.djs, null);
    });

    test('copyWith should create a new instance with updated fields', () {
      final eventPart = EventPart(
        name: 'Workshop',
        type: EventPartType.workshop,
        startTime: startTime,
        endTime: endTime,
        lectors: ['Teacher 1'],
      );

      final newStartTime = DateTime(2024, 1, 15, 20, 0);
      final updated = eventPart.copyWith(
        name: 'Advanced Workshop',
        startTime: newStartTime,
        lectors: ['Teacher 1', 'Teacher 2'],
      );

      expect(updated.name, 'Advanced Workshop');
      expect(updated.type, EventPartType.workshop);
      expect(updated.startTime, newStartTime);
      expect(updated.endTime, endTime);
      expect(updated.lectors, ['Teacher 1', 'Teacher 2']);
      expect(identical(eventPart, updated), false);
    });

    test('copyWith should return same values when no parameters provided', () {
      final eventPart = EventPart(
        name: 'Workshop',
        description: 'Test workshop',
        type: EventPartType.workshop,
        startTime: startTime,
        endTime: endTime,
        lectors: ['Teacher 1'],
      );

      final copied = eventPart.copyWith();

      expect(copied.name, eventPart.name);
      expect(copied.description, eventPart.description);
      expect(copied.type, eventPart.type);
      expect(copied.startTime, eventPart.startTime);
      expect(copied.endTime, eventPart.endTime);
      expect(copied.lectors, eventPart.lectors);
      expect(copied.djs, eventPart.djs);
    });

    test('should support value equality', () {
      final eventPart1 = EventPart(
        name: 'Workshop',
        description: 'Test workshop',
        type: EventPartType.workshop,
        startTime: startTime,
        endTime: endTime,
        lectors: ['Teacher 1'],
      );

      final eventPart2 = EventPart(
        name: 'Workshop',
        description: 'Test workshop',
        type: EventPartType.workshop,
        startTime: startTime,
        endTime: endTime,
        lectors: ['Teacher 1'],
      );

      expect(eventPart1, equals(eventPart2));
      expect(eventPart1.hashCode, equals(eventPart2.hashCode));
    });

    test('should not be equal when fields differ', () {
      final eventPart1 = EventPart(
        name: 'Workshop',
        type: EventPartType.workshop,
        startTime: startTime,
        endTime: endTime,
      );

      final eventPart2 = EventPart(
        name: 'Party',
        type: EventPartType.party,
        startTime: startTime,
        endTime: endTime,
      );

      expect(eventPart1, isNot(equals(eventPart2)));
    });

    test('should not be equal when DateTime differs', () {
      final eventPart1 = EventPart(
        name: 'Workshop',
        type: EventPartType.workshop,
        startTime: startTime,
        endTime: endTime,
      );

      final differentStartTime = DateTime(2024, 1, 15, 20, 0);
      final eventPart2 = EventPart(
        name: 'Workshop',
        type: EventPartType.workshop,
        startTime: differentStartTime,
        endTime: endTime,
      );

      expect(eventPart1, isNot(equals(eventPart2)));
    });

    test('EventPartType enum should have all expected values', () {
      expect(EventPartType.values.length, 3);
      expect(EventPartType.values, contains(EventPartType.party));
      expect(EventPartType.values, contains(EventPartType.workshop));
      expect(EventPartType.values, contains(EventPartType.openLesson));
    });
  });
}
