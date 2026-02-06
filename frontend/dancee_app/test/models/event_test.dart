import 'package:flutter_test/flutter_test.dart';
import 'package:dancee_shared/dancee_shared.dart';

void main() {
  group('Event', () {
    const testAddress = Address(
      street: 'Vodičkova 36',
      city: 'Prague',
      postalCode: '110 00',
      country: 'Czech Republic',
    );

    const testVenue = Venue(
      name: 'Lucerna Music Bar',
      address: testAddress,
      description: 'Historic music venue in the heart of Prague',
      latitude: 50.0813,
      longitude: 14.4253,
    );

    final startTime = DateTime(2024, 1, 15, 20, 0);
    final endTime = DateTime(2024, 1, 16, 2, 0);
    const duration = Duration(hours: 6);

    test('should create an Event with all required fields', () {
      final event = Event(
        id: '1',
        title: 'Salsa Social Night',
        description: 'Join us for an amazing night of Salsa dancing!',
        organizer: 'Prague Dance Events',
        venue: testVenue,
        startTime: startTime,
        endTime: endTime,
        duration: duration,
        dances: ['Salsa', 'Bachata', 'Kizomba'],
      );

      expect(event.id, '1');
      expect(event.title, 'Salsa Social Night');
      expect(event.description, 'Join us for an amazing night of Salsa dancing!');
      expect(event.organizer, 'Prague Dance Events');
      expect(event.venue, testVenue);
      expect(event.startTime, startTime);
      expect(event.endTime, endTime);
      expect(event.duration, duration);
      expect(event.dances, ['Salsa', 'Bachata', 'Kizomba']);
      expect(event.info, []);
      expect(event.parts, []);
      expect(event.isFavorite, false);
      expect(event.isPast, false);
      expect(event.badge, null);
    });

    test('should create Event with info and parts', () {
      const eventInfo = EventInfo(
        type: EventInfoType.price,
        key: 'Entry Fee',
        value: '150 Kč',
      );

      final eventPart = EventPart(
        name: 'Social Dancing',
        type: EventPartType.party,
        startTime: startTime,
        endTime: endTime,
        djs: ['DJ Carlos'],
      );

      final event = Event(
        id: '1',
        title: 'Salsa Social Night',
        description: 'Join us for an amazing night of Salsa dancing!',
        organizer: 'Prague Dance Events',
        venue: testVenue,
        startTime: startTime,
        endTime: endTime,
        duration: duration,
        dances: ['Salsa'],
        info: [eventInfo],
        parts: [eventPart],
      );

      expect(event.info.length, 1);
      expect(event.info.first, eventInfo);
      expect(event.parts.length, 1);
      expect(event.parts.first, eventPart);
    });

    test('should create Event with favorite and past flags', () {
      final event = Event(
        id: '1',
        title: 'Salsa Social Night',
        description: 'Join us for an amazing night of Salsa dancing!',
        organizer: 'Prague Dance Events',
        venue: testVenue,
        startTime: startTime,
        endTime: endTime,
        duration: duration,
        dances: ['Salsa'],
        isFavorite: true,
        isPast: true,
        badge: 'FINISHED',
      );

      expect(event.isFavorite, true);
      expect(event.isPast, true);
      expect(event.badge, 'FINISHED');
    });

    test('copyWith should create a new instance with updated fields', () {
      final event = Event(
        id: '1',
        title: 'Salsa Social Night',
        description: 'Join us for an amazing night of Salsa dancing!',
        organizer: 'Prague Dance Events',
        venue: testVenue,
        startTime: startTime,
        endTime: endTime,
        duration: duration,
        dances: ['Salsa'],
        isFavorite: false,
      );

      final updated = event.copyWith(
        title: 'Bachata Social Night',
        dances: ['Bachata'],
        isFavorite: true,
      );

      expect(updated.id, '1');
      expect(updated.title, 'Bachata Social Night');
      expect(updated.description, 'Join us for an amazing night of Salsa dancing!');
      expect(updated.dances, ['Bachata']);
      expect(updated.isFavorite, true);
      expect(identical(event, updated), false);
    });

    test('copyWith should toggle favorite status', () {
      final event = Event(
        id: '1',
        title: 'Salsa Social Night',
        description: 'Join us for an amazing night of Salsa dancing!',
        organizer: 'Prague Dance Events',
        venue: testVenue,
        startTime: startTime,
        endTime: endTime,
        duration: duration,
        dances: ['Salsa'],
        isFavorite: false,
      );

      final favorited = event.copyWith(isFavorite: true);
      expect(event.isFavorite, false);
      expect(favorited.isFavorite, true);

      final unfavorited = favorited.copyWith(isFavorite: false);
      expect(favorited.isFavorite, true);
      expect(unfavorited.isFavorite, false);
    });

    test('copyWith should return same values when no parameters provided', () {
      final event = Event(
        id: '1',
        title: 'Salsa Social Night',
        description: 'Join us for an amazing night of Salsa dancing!',
        organizer: 'Prague Dance Events',
        venue: testVenue,
        startTime: startTime,
        endTime: endTime,
        duration: duration,
        dances: ['Salsa'],
      );

      final copied = event.copyWith();

      expect(copied.id, event.id);
      expect(copied.title, event.title);
      expect(copied.description, event.description);
      expect(copied.organizer, event.organizer);
      expect(copied.venue, event.venue);
      expect(copied.startTime, event.startTime);
      expect(copied.endTime, event.endTime);
      expect(copied.duration, event.duration);
      expect(copied.dances, event.dances);
      expect(copied.info, event.info);
      expect(copied.parts, event.parts);
      expect(copied.isFavorite, event.isFavorite);
      expect(copied.isPast, event.isPast);
      expect(copied.badge, event.badge);
    });

    test('should support value equality', () {
      final event1 = Event(
        id: '1',
        title: 'Salsa Social Night',
        description: 'Join us for an amazing night of Salsa dancing!',
        organizer: 'Prague Dance Events',
        venue: testVenue,
        startTime: startTime,
        endTime: endTime,
        duration: duration,
        dances: ['Salsa'],
      );

      final event2 = Event(
        id: '1',
        title: 'Salsa Social Night',
        description: 'Join us for an amazing night of Salsa dancing!',
        organizer: 'Prague Dance Events',
        venue: testVenue,
        startTime: startTime,
        endTime: endTime,
        duration: duration,
        dances: ['Salsa'],
      );

      expect(event1, equals(event2));
      expect(event1.hashCode, equals(event2.hashCode));
    });

    test('should not be equal when fields differ', () {
      final event1 = Event(
        id: '1',
        title: 'Salsa Social Night',
        description: 'Join us for an amazing night of Salsa dancing!',
        organizer: 'Prague Dance Events',
        venue: testVenue,
        startTime: startTime,
        endTime: endTime,
        duration: duration,
        dances: ['Salsa'],
      );

      final event2 = Event(
        id: '2',
        title: 'Bachata Social Night',
        description: 'Join us for an amazing night of Bachata dancing!',
        organizer: 'Prague Dance Events',
        venue: testVenue,
        startTime: startTime,
        endTime: endTime,
        duration: duration,
        dances: ['Bachata'],
      );

      expect(event1, isNot(equals(event2)));
    });

    test('should not be equal when favorite status differs', () {
      final event1 = Event(
        id: '1',
        title: 'Salsa Social Night',
        description: 'Join us for an amazing night of Salsa dancing!',
        organizer: 'Prague Dance Events',
        venue: testVenue,
        startTime: startTime,
        endTime: endTime,
        duration: duration,
        dances: ['Salsa'],
        isFavorite: false,
      );

      final event2 = Event(
        id: '1',
        title: 'Salsa Social Night',
        description: 'Join us for an amazing night of Salsa dancing!',
        organizer: 'Prague Dance Events',
        venue: testVenue,
        startTime: startTime,
        endTime: endTime,
        duration: duration,
        dances: ['Salsa'],
        isFavorite: true,
      );

      expect(event1, isNot(equals(event2)));
    });

    test('should handle DateTime and Duration correctly', () {
      final event = Event(
        id: '1',
        title: 'Salsa Social Night',
        description: 'Join us for an amazing night of Salsa dancing!',
        organizer: 'Prague Dance Events',
        venue: testVenue,
        startTime: startTime,
        endTime: endTime,
        duration: duration,
        dances: ['Salsa'],
      );

      expect(event.startTime.year, 2024);
      expect(event.startTime.month, 1);
      expect(event.startTime.day, 15);
      expect(event.startTime.hour, 20);
      expect(event.duration.inHours, 6);
    });

    test('should handle multiple dances', () {
      final event = Event(
        id: '1',
        title: 'Latin Mix Party',
        description: 'All Latin dances welcome!',
        organizer: 'Prague Dance Events',
        venue: testVenue,
        startTime: startTime,
        endTime: endTime,
        duration: duration,
        dances: ['Salsa', 'Bachata', 'Kizomba', 'Zouk', 'Tango'],
      );

      expect(event.dances.length, 5);
      expect(event.dances, contains('Salsa'));
      expect(event.dances, contains('Bachata'));
      expect(event.dances, contains('Kizomba'));
      expect(event.dances, contains('Zouk'));
      expect(event.dances, contains('Tango'));
    });

    test('should handle multiple event info items', () {
      const info1 = EventInfo(
        type: EventInfoType.price,
        key: 'Entry Fee',
        value: '150 Kč',
      );

      const info2 = EventInfo(
        type: EventInfoType.url,
        key: 'Facebook Event',
        value: 'https://facebook.com/events/123',
      );

      const info3 = EventInfo(
        type: EventInfoType.text,
        key: 'Dress Code',
        value: 'Casual',
      );

      final event = Event(
        id: '1',
        title: 'Salsa Social Night',
        description: 'Join us for an amazing night of Salsa dancing!',
        organizer: 'Prague Dance Events',
        venue: testVenue,
        startTime: startTime,
        endTime: endTime,
        duration: duration,
        dances: ['Salsa'],
        info: [info1, info2, info3],
      );

      expect(event.info.length, 3);
      expect(event.info[0].type, EventInfoType.price);
      expect(event.info[1].type, EventInfoType.url);
      expect(event.info[2].type, EventInfoType.text);
    });

    test('should handle multiple event parts', () {
      final part1 = EventPart(
        name: 'Workshop',
        type: EventPartType.workshop,
        startTime: startTime,
        endTime: startTime.add(Duration(hours: 1, minutes: 30)),
        lectors: ['Teacher 1'],
      );

      final part2 = EventPart(
        name: 'Party',
        type: EventPartType.party,
        startTime: startTime.add(Duration(hours: 1, minutes: 30)),
        endTime: endTime,
        djs: ['DJ 1'],
      );

      final event = Event(
        id: '1',
        title: 'Workshop & Party',
        description: 'Workshop followed by social dancing',
        organizer: 'Prague Dance Events',
        venue: testVenue,
        startTime: startTime,
        endTime: endTime,
        duration: duration,
        dances: ['Salsa'],
        parts: [part1, part2],
      );

      expect(event.parts.length, 2);
      expect(event.parts[0].type, EventPartType.workshop);
      expect(event.parts[1].type, EventPartType.party);
    });
  });
}
