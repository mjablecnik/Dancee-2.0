import 'package:test/test.dart';
import 'package:dancee_shared/dancee_shared.dart';

void main() {
  group('JSON Serialization Tests', () {
    test('Address toJson and fromJson round-trip', () {
      final address = Address(
        street: 'Vodičkova 36',
        city: 'Prague',
        postalCode: '110 00',
        country: 'Czech Republic',
      );

      final json = address.toJson();
      final restored = Address.fromJson(json);

      expect(restored, equals(address));
      expect(json['street'], equals('Vodičkova 36'));
      expect(json['city'], equals('Prague'));
    });

    test('Venue toJson and fromJson round-trip', () {
      final venue = Venue(
        name: 'Dance Studio',
        address: Address(
          street: 'Main Street 1',
          city: 'Prague',
          postalCode: '110 00',
          country: 'Czech Republic',
        ),
        description: 'A great dance venue',
        latitude: 50.0755,
        longitude: 14.4378,
      );

      final json = venue.toJson();
      final restored = Venue.fromJson(json);

      expect(restored, equals(venue));
      expect(json['name'], equals('Dance Studio'));
      expect(json['latitude'], equals(50.0755));
    });

    test('EventInfo toJson and fromJson with enum serialization', () {
      final eventInfo = EventInfo(
        type: EventInfoType.price,
        key: 'Entry Fee',
        value: '150 Kč',
      );

      final json = eventInfo.toJson();
      final restored = EventInfo.fromJson(json);

      expect(restored, equals(eventInfo));
      expect(json['type'], equals('price')); // Enum serialized as string
      expect(json['key'], equals('Entry Fee'));
    });

    test('EventPart toJson and fromJson with ISO 8601 dates', () {
      final startTime = DateTime.parse('2024-01-15T20:00:00.000Z');
      final endTime = DateTime.parse('2024-01-16T02:00:00.000Z');

      final eventPart = EventPart(
        name: 'Social Dancing',
        description: 'Open social dancing',
        type: EventPartType.party,
        startTime: startTime,
        endTime: endTime,
        djs: ['DJ Carlos'],
      );

      final json = eventPart.toJson();
      final restored = EventPart.fromJson(json);

      expect(restored, equals(eventPart));
      expect(json['type'], equals('party')); // Enum serialized as string
      expect(json['startTime'], equals('2024-01-15T20:00:00.000Z')); // ISO 8601
      expect(json['djs'], equals(['DJ Carlos']));
    });

    test('Event toJson and fromJson with duration as seconds', () {
      final startTime = DateTime.parse('2024-01-15T20:00:00.000Z');
      final endTime = DateTime.parse('2024-01-16T02:00:00.000Z');
      final duration = Duration(hours: 6); // 21600 seconds

      final event = Event(
        id: 'event-1',
        title: 'Salsa Night',
        description: 'A great salsa event',
        organizer: 'Dance Club',
        venue: Venue(
          name: 'Dance Studio',
          address: Address(
            street: 'Main Street 1',
            city: 'Prague',
            postalCode: '110 00',
            country: 'Czech Republic',
          ),
          description: 'A great venue',
          latitude: 50.0755,
          longitude: 14.4378,
        ),
        startTime: startTime,
        endTime: endTime,
        duration: duration,
        dances: ['Salsa', 'Bachata'],
        info: [
          EventInfo(
            type: EventInfoType.price,
            key: 'Entry Fee',
            value: '150 Kč',
          ),
        ],
        parts: [
          EventPart(
            name: 'Social Dancing',
            description: 'Open social dancing',
            type: EventPartType.party,
            startTime: startTime,
            endTime: endTime,
            djs: ['DJ Carlos'],
          ),
        ],
        isFavorite: false,
        isPast: false,
      );

      final json = event.toJson();
      final restored = Event.fromJson(json);

      expect(restored, equals(event));
      expect(json['duration'], equals(21600)); // Duration as seconds
      expect(json['startTime'], equals('2024-01-15T20:00:00.000Z')); // ISO 8601
      expect(json['dances'], equals(['Salsa', 'Bachata']));
      expect(json['info'], isA<List>());
      expect(json['parts'], isA<List>());
    });

    test('Event with null optional fields serializes correctly', () {
      final event = Event(
        id: 'event-2',
        title: 'Simple Event',
        description: 'Description',
        organizer: 'Organizer',
        venue: Venue(
          name: 'Venue',
          address: Address(
            street: 'Street',
            city: 'City',
            postalCode: '12345',
            country: 'Country',
          ),
          description: 'Venue desc',
          latitude: 0.0,
          longitude: 0.0,
        ),
        startTime: DateTime.now(),
        endTime: DateTime.now().add(Duration(hours: 2)),
        duration: Duration(hours: 2),
        dances: ['Dance'],
        badge: null, // Explicitly null
      );

      final json = event.toJson();
      final restored = Event.fromJson(json);

      expect(restored, equals(event));
      expect(json['badge'], isNull);
      expect(restored.badge, isNull);
    });
  });
}
