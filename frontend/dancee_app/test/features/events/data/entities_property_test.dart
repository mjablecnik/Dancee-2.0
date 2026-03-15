import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:dancee_app/features/events/data/entities.dart';

/// Feature: flutter-architecture-refactor
/// Property 1: Entity Serialization Round-Trip
/// **Validates: Requirements 2.2, 6.2, 6.3**

// ============================================================================
// Random generators
// ============================================================================

String _randomString(Random rng, {int maxLength = 20}) {
  final length = rng.nextInt(maxLength) + 1;
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ';
  return String.fromCharCodes(
    Iterable.generate(length, (_) => chars.codeUnitAt(rng.nextInt(chars.length))),
  );
}

String? _randomNullableString(Random rng, {int maxLength = 20}) {
  return rng.nextBool() ? _randomString(rng, maxLength: maxLength) : null;
}

List<String> _randomStringList(Random rng, {int maxLength = 5}) {
  final length = rng.nextInt(maxLength);
  return List.generate(length, (_) => _randomString(rng));
}

List<String>? _randomNullableStringList(Random rng, {int maxLength = 5}) {
  return rng.nextBool() ? _randomStringList(rng, maxLength: maxLength) : null;
}

DateTime _randomDateTime(Random rng) {
  // Generate dates between 2020-2030, truncated to milliseconds
  // (DateTime.parse of ISO 8601 preserves millisecond precision)
  final year = 2020 + rng.nextInt(10);
  final month = 1 + rng.nextInt(12);
  final day = 1 + rng.nextInt(28);
  final hour = rng.nextInt(24);
  final minute = rng.nextInt(60);
  final second = rng.nextInt(60);
  final millisecond = rng.nextInt(1000);
  return DateTime(year, month, day, hour, minute, second, millisecond);
}

double _randomLatitude(Random rng) {
  // -90 to 90, rounded to avoid floating point drift
  return double.parse(((rng.nextDouble() * 180) - 90).toStringAsFixed(6));
}

double _randomLongitude(Random rng) {
  // -180 to 180, rounded to avoid floating point drift
  return double.parse(((rng.nextDouble() * 360) - 180).toStringAsFixed(6));
}

Address _randomAddress(Random rng) {
  return Address(
    street: _randomString(rng),
    city: _randomString(rng),
    postalCode: _randomString(rng, maxLength: 10),
    country: _randomString(rng),
  );
}

Venue _randomVenue(Random rng) {
  return Venue(
    name: _randomString(rng),
    address: _randomAddress(rng),
    description: _randomString(rng),
    latitude: _randomLatitude(rng),
    longitude: _randomLongitude(rng),
  );
}

EventInfoType _randomEventInfoType(Random rng) {
  return EventInfoType.values[rng.nextInt(EventInfoType.values.length)];
}

EventInfo _randomEventInfo(Random rng) {
  return EventInfo(
    type: _randomEventInfoType(rng),
    key: _randomString(rng),
    value: _randomString(rng),
  );
}

EventPartType _randomEventPartType(Random rng) {
  return EventPartType.values[rng.nextInt(EventPartType.values.length)];
}

EventPart _randomEventPart(Random rng) {
  final start = _randomDateTime(rng);
  final end = start.add(Duration(minutes: 30 + rng.nextInt(180)));
  return EventPart(
    name: _randomString(rng),
    description: _randomNullableString(rng),
    type: _randomEventPartType(rng),
    startTime: start,
    endTime: end,
    lectors: _randomNullableStringList(rng),
    djs: _randomNullableStringList(rng),
  );
}

Event _randomEvent(Random rng) {
  final start = _randomDateTime(rng);
  final durationMinutes = 30 + rng.nextInt(480);
  final end = start.add(Duration(minutes: durationMinutes));
  final infoCount = rng.nextInt(4);
  final partsCount = rng.nextInt(4);

  return Event(
    id: _randomString(rng),
    title: _randomString(rng),
    description: _randomString(rng),
    organizer: _randomString(rng),
    venue: _randomVenue(rng),
    startTime: start,
    endTime: end,
    duration: Duration(minutes: durationMinutes),
    dances: _randomStringList(rng, maxLength: 6),
    info: List.generate(infoCount, (_) => _randomEventInfo(rng)),
    parts: List.generate(partsCount, (_) => _randomEventPart(rng)),
    isFavorite: rng.nextBool(),
    isPast: rng.nextBool(),
    badge: _randomNullableString(rng, maxLength: 10),
  );
}

// ============================================================================
// Tests
// ============================================================================

void main() {
  group('Property 1: Entity Serialization Round-Trip', () {
    test('Address toJson then fromJson preserves all fields', () {
      for (var i = 0; i < 100; i++) {
        final rng = Random(i);
        final original = _randomAddress(rng);
        final json = original.toJson();
        final restored = Address.fromJson(json);
        expect(restored, equals(original), reason: 'Failed at seed $i');
      }
    });

    test('Venue toJson then fromJson preserves all fields', () {
      for (var i = 0; i < 100; i++) {
        final rng = Random(i);
        final original = _randomVenue(rng);
        final json = original.toJson();
        final restored = Venue.fromJson(json);
        expect(restored, equals(original), reason: 'Failed at seed $i');
      }
    });

    test('EventInfo toJson then fromJson preserves all fields', () {
      for (var i = 0; i < 100; i++) {
        final rng = Random(i);
        final original = _randomEventInfo(rng);
        final json = original.toJson();
        final restored = EventInfo.fromJson(json);
        expect(restored, equals(original), reason: 'Failed at seed $i');
      }
    });

    test('EventPart toJson then fromJson preserves all fields', () {
      for (var i = 0; i < 100; i++) {
        final rng = Random(i);
        final original = _randomEventPart(rng);
        final json = original.toJson();
        final restored = EventPart.fromJson(json);
        expect(restored, equals(original), reason: 'Failed at seed $i');
      }
    });

    test('Event toJson then fromJson preserves all fields', () {
      for (var i = 0; i < 100; i++) {
        final rng = Random(i);
        final original = _randomEvent(rng);
        final json = original.toJson();
        final restored = Event.fromJson(json);
        expect(restored, equals(original), reason: 'Failed at seed $i');
      }
    });
  });
}
