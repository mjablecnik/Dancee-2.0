import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:dancee_app/features/events/data/entities.dart';

/// Feature: flutter-architecture-refactor
/// Property 3: Entity Value Equality
/// **Validates: Requirements 6.5**

// ============================================================================
// Random generators (copied from entities_property_test.dart)
// ============================================================================

String _randomString(Random rng, {int maxLength = 20}) {
  final length = rng.nextInt(maxLength) + 1;
  const chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ';
  return String.fromCharCodes(
    Iterable.generate(
        length, (_) => chars.codeUnitAt(rng.nextInt(chars.length))),
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
  return double.parse(((rng.nextDouble() * 180) - 90).toStringAsFixed(6));
}

double _randomLongitude(Random rng) {
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
// Helpers for generating a "different" value
// ============================================================================

/// Returns a string guaranteed to differ from [original].
String _differentString(Random rng, String original) {
  String result;
  do {
    result = _randomString(rng);
  } while (result == original);
  return result;
}

double _differentDouble(Random rng, double original) {
  double result;
  do {
    result = double.parse(((rng.nextDouble() * 360) - 180).toStringAsFixed(6));
  } while (result == original);
  return result;
}

bool _differentBool(bool original) => !original;

DateTime _differentDateTime(Random rng, DateTime original) {
  // Simply add a random non-zero offset
  return original.add(Duration(days: 1 + rng.nextInt(30)));
}

Duration _differentDuration(Random rng, Duration original) {
  return original + Duration(minutes: 1 + rng.nextInt(60));
}

EventInfoType _differentEventInfoType(EventInfoType original) {
  final values = EventInfoType.values;
  return values[(values.indexOf(original) + 1) % values.length];
}

EventPartType _differentEventPartType(EventPartType original) {
  final values = EventPartType.values;
  return values[(values.indexOf(original) + 1) % values.length];
}

// ============================================================================
// Tests
// ============================================================================

void main() {
  group('Property 3: Entity Value Equality', () {
    // ------------------------------------------------------------------
    // Address
    // ------------------------------------------------------------------
    group('Address', () {
      test('identical field values produce equal instances with same hashCode',
          () {
        for (var i = 0; i < 100; i++) {
          final rng = Random(i);
          final a = _randomAddress(rng);
          final copy = a.copyWith();
          expect(copy, equals(a), reason: 'Equality failed at seed $i');
          expect(copy.hashCode, equals(a.hashCode),
              reason: 'hashCode mismatch at seed $i');
        }
      });

      test('changing one field produces a non-equal instance', () {
        for (var i = 0; i < 100; i++) {
          final rng = Random(i);
          final a = _randomAddress(rng);
          final fieldIndex = rng.nextInt(4);
          final Address modified;
          switch (fieldIndex) {
            case 0:
              modified = a.copyWith(street: _differentString(rng, a.street));
              break;
            case 1:
              modified = a.copyWith(city: _differentString(rng, a.city));
              break;
            case 2:
              modified =
                  a.copyWith(postalCode: _differentString(rng, a.postalCode));
              break;
            default:
              modified = a.copyWith(country: _differentString(rng, a.country));
          }
          expect(modified, isNot(equals(a)),
              reason:
                  'Should differ when field $fieldIndex changed at seed $i');
        }
      });
    });

    // ------------------------------------------------------------------
    // Venue
    // ------------------------------------------------------------------
    group('Venue', () {
      test('identical field values produce equal instances with same hashCode',
          () {
        for (var i = 0; i < 100; i++) {
          final rng = Random(i);
          final v = _randomVenue(rng);
          final copy = v.copyWith();
          expect(copy, equals(v), reason: 'Equality failed at seed $i');
          expect(copy.hashCode, equals(v.hashCode),
              reason: 'hashCode mismatch at seed $i');
        }
      });

      test('changing one field produces a non-equal instance', () {
        for (var i = 0; i < 100; i++) {
          final rng = Random(i);
          final v = _randomVenue(rng);
          final fieldIndex = rng.nextInt(5);
          final Venue modified;
          switch (fieldIndex) {
            case 0:
              modified = v.copyWith(name: _differentString(rng, v.name));
              break;
            case 1:
              modified = v.copyWith(address: _randomAddress(Random(i + 9999)));
              break;
            case 2:
              modified = v.copyWith(
                  description: _differentString(rng, v.description));
              break;
            case 3:
              modified =
                  v.copyWith(latitude: _differentDouble(rng, v.latitude));
              break;
            default:
              modified =
                  v.copyWith(longitude: _differentDouble(rng, v.longitude));
          }
          expect(modified, isNot(equals(v)),
              reason:
                  'Should differ when field $fieldIndex changed at seed $i');
        }
      });
    });

    // ------------------------------------------------------------------
    // EventInfo
    // ------------------------------------------------------------------
    group('EventInfo', () {
      test('identical field values produce equal instances with same hashCode',
          () {
        for (var i = 0; i < 100; i++) {
          final rng = Random(i);
          final ei = _randomEventInfo(rng);
          final copy = ei.copyWith();
          expect(copy, equals(ei), reason: 'Equality failed at seed $i');
          expect(copy.hashCode, equals(ei.hashCode),
              reason: 'hashCode mismatch at seed $i');
        }
      });

      test('changing one field produces a non-equal instance', () {
        for (var i = 0; i < 100; i++) {
          final rng = Random(i);
          final ei = _randomEventInfo(rng);
          final fieldIndex = rng.nextInt(3);
          final EventInfo modified;
          switch (fieldIndex) {
            case 0:
              modified =
                  ei.copyWith(type: _differentEventInfoType(ei.type));
              break;
            case 1:
              modified = ei.copyWith(key: _differentString(rng, ei.key));
              break;
            default:
              modified = ei.copyWith(value: _differentString(rng, ei.value));
          }
          expect(modified, isNot(equals(ei)),
              reason:
                  'Should differ when field $fieldIndex changed at seed $i');
        }
      });
    });

    // ------------------------------------------------------------------
    // EventPart
    // ------------------------------------------------------------------
    group('EventPart', () {
      test('identical field values produce equal instances with same hashCode',
          () {
        for (var i = 0; i < 100; i++) {
          final rng = Random(i);
          final ep = _randomEventPart(rng);
          final copy = ep.copyWith();
          expect(copy, equals(ep), reason: 'Equality failed at seed $i');
          expect(copy.hashCode, equals(ep.hashCode),
              reason: 'hashCode mismatch at seed $i');
        }
      });

      test('changing one field produces a non-equal instance', () {
        for (var i = 0; i < 100; i++) {
          final rng = Random(i);
          final ep = _randomEventPart(rng);
          // Pick from the 5 required fields (name, type, startTime, endTime,
          // and description which is nullable but still in props)
          final fieldIndex = rng.nextInt(5);
          final EventPart modified;
          switch (fieldIndex) {
            case 0:
              modified = ep.copyWith(name: _differentString(rng, ep.name));
              break;
            case 1:
              modified =
                  ep.copyWith(type: _differentEventPartType(ep.type));
              break;
            case 2:
              modified = ep.copyWith(
                  startTime: _differentDateTime(rng, ep.startTime));
              break;
            case 3:
              modified =
                  ep.copyWith(endTime: _differentDateTime(rng, ep.endTime));
              break;
            default:
              // Change description: if null make non-null, if non-null change it
              modified = ep.copyWith(
                description: ep.description == null
                    ? _randomString(rng)
                    : _differentString(rng, ep.description!),
              );
          }
          expect(modified, isNot(equals(ep)),
              reason:
                  'Should differ when field $fieldIndex changed at seed $i');
        }
      });
    });

    // ------------------------------------------------------------------
    // Event
    // ------------------------------------------------------------------
    group('Event', () {
      test('identical field values produce equal instances with same hashCode',
          () {
        for (var i = 0; i < 100; i++) {
          final rng = Random(i);
          final e = _randomEvent(rng);
          final copy = e.copyWith();
          expect(copy, equals(e), reason: 'Equality failed at seed $i');
          expect(copy.hashCode, equals(e.hashCode),
              reason: 'hashCode mismatch at seed $i');
        }
      });

      test('changing one field produces a non-equal instance', () {
        for (var i = 0; i < 100; i++) {
          final rng = Random(i);
          final e = _randomEvent(rng);
          // Pick one of the 14 fields in Event.props
          final fieldIndex = rng.nextInt(14);
          final Event modified;
          switch (fieldIndex) {
            case 0:
              modified = e.copyWith(id: _differentString(rng, e.id));
              break;
            case 1:
              modified = e.copyWith(title: _differentString(rng, e.title));
              break;
            case 2:
              modified = e.copyWith(
                  description: _differentString(rng, e.description));
              break;
            case 3:
              modified =
                  e.copyWith(organizer: _differentString(rng, e.organizer));
              break;
            case 4:
              modified = e.copyWith(venue: _randomVenue(Random(i + 9999)));
              break;
            case 5:
              modified = e.copyWith(
                  startTime: _differentDateTime(rng, e.startTime));
              break;
            case 6:
              modified =
                  e.copyWith(endTime: _differentDateTime(rng, e.endTime));
              break;
            case 7:
              modified =
                  e.copyWith(duration: _differentDuration(rng, e.duration));
              break;
            case 8:
              // Change dances list by appending a unique element
              modified =
                  e.copyWith(dances: [...e.dances, _randomString(rng)]);
              break;
            case 9:
              // Change info list by appending a new EventInfo
              modified = e.copyWith(
                  info: [...e.info, _randomEventInfo(Random(i + 7777))]);
              break;
            case 10:
              // Change parts list by appending a new EventPart
              modified = e.copyWith(
                  parts: [...e.parts, _randomEventPart(Random(i + 8888))]);
              break;
            case 11:
              modified =
                  e.copyWith(isFavorite: _differentBool(e.isFavorite));
              break;
            case 12:
              modified = e.copyWith(isPast: _differentBool(e.isPast));
              break;
            default:
              // Change badge: if null make non-null, if non-null change it
              modified = e.copyWith(
                badge: e.badge == null
                    ? _randomString(rng)
                    : _differentString(rng, e.badge!),
              );
          }
          expect(modified, isNot(equals(e)),
              reason:
                  'Should differ when field $fieldIndex changed at seed $i');
        }
      });
    });
  });
}
