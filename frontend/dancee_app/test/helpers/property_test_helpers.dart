import 'dart:math';

import 'package:dancee_app/features/events/data/entities.dart';

// =============================================================================
// Random primitive generators
// =============================================================================

/// Generates a random non-empty string of up to [maxLength] characters.
String randomString(Random rng, {int maxLength = 20}) {
  final length = rng.nextInt(maxLength) + 1;
  const chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ';
  return String.fromCharCodes(
    Iterable.generate(
        length, (_) => chars.codeUnitAt(rng.nextInt(chars.length))),
  );
}

/// Generates a random nullable string.
String? randomNullableString(Random rng, {int maxLength = 20}) {
  return rng.nextBool() ? randomString(rng, maxLength: maxLength) : null;
}

/// Generates a random list of strings.
List<String> randomStringList(Random rng, {int maxLength = 5}) {
  final length = rng.nextInt(maxLength);
  return List.generate(length, (_) => randomString(rng));
}

/// Generates a random nullable list of strings.
List<String>? randomNullableStringList(Random rng, {int maxLength = 5}) {
  return rng.nextBool() ? randomStringList(rng, maxLength: maxLength) : null;
}

/// Generates a random DateTime between 2020 and 2030, truncated to ms.
DateTime randomDateTime(Random rng) {
  final year = 2020 + rng.nextInt(10);
  final month = 1 + rng.nextInt(12);
  final day = 1 + rng.nextInt(28);
  final hour = rng.nextInt(24);
  final minute = rng.nextInt(60);
  final second = rng.nextInt(60);
  final millisecond = rng.nextInt(1000);
  return DateTime(year, month, day, hour, minute, second, millisecond);
}

/// Generates a random latitude (-90 to 90).
double randomLatitude(Random rng) {
  return double.parse(((rng.nextDouble() * 180) - 90).toStringAsFixed(6));
}

/// Generates a random longitude (-180 to 180).
double randomLongitude(Random rng) {
  return double.parse(((rng.nextDouble() * 360) - 180).toStringAsFixed(6));
}

// =============================================================================
// Random entity generators
// =============================================================================

/// Generates a random Address.
Address randomAddress(Random rng) {
  return Address(
    street: randomString(rng),
    city: randomString(rng),
    postalCode: randomString(rng, maxLength: 10),
    country: randomString(rng),
  );
}

/// Generates a random Venue.
Venue randomVenue(Random rng) {
  return Venue(
    name: randomString(rng),
    address: randomAddress(rng),
    description: randomString(rng),
    latitude: randomLatitude(rng),
    longitude: randomLongitude(rng),
  );
}

/// Generates a random EventInfoType.
EventInfoType randomEventInfoType(Random rng) {
  return EventInfoType.values[rng.nextInt(EventInfoType.values.length)];
}

/// Generates a random EventInfo.
EventInfo randomEventInfo(Random rng) {
  return EventInfo(
    type: randomEventInfoType(rng),
    key: randomString(rng),
    value: randomString(rng),
  );
}

/// Generates a random EventPartType.
EventPartType randomEventPartType(Random rng) {
  return EventPartType.values[rng.nextInt(EventPartType.values.length)];
}

/// Generates a random EventPart.
EventPart randomEventPart(Random rng) {
  final start = randomDateTime(rng);
  final end = start.add(Duration(minutes: 30 + rng.nextInt(180)));
  return EventPart(
    name: randomString(rng),
    description: randomNullableString(rng),
    type: randomEventPartType(rng),
    startTime: start,
    endTime: end,
    lectors: randomNullableStringList(rng),
    djs: randomNullableStringList(rng),
  );
}

/// Generates a random Event with all fields populated.
Event randomEvent(Random rng) {
  final start = randomDateTime(rng);
  final durationMinutes = 30 + rng.nextInt(480);
  final end = start.add(Duration(minutes: durationMinutes));
  final infoCount = rng.nextInt(4);
  final partsCount = rng.nextInt(4);

  return Event(
    id: randomString(rng),
    title: randomString(rng),
    description: randomString(rng),
    organizer: randomString(rng),
    venue: randomVenue(rng),
    startTime: start,
    endTime: end,
    duration: Duration(minutes: durationMinutes),
    dances: randomStringList(rng, maxLength: 6),
    info: List.generate(infoCount, (_) => randomEventInfo(rng)),
    parts: List.generate(partsCount, (_) => randomEventPart(rng)),
    isFavorite: rng.nextBool(),
    isPast: rng.nextBool(),
    badge: randomNullableString(rng, maxLength: 10),
  );
}

// =============================================================================
// JSON factory helpers
// =============================================================================

/// Creates a valid event JSON map for testing repository parsing.
Map<String, dynamic> createEventJson({
  String id = '1',
  String title = 'Test Event',
  bool isFavorite = false,
  bool isPast = false,
}) {
  return {
    'id': id,
    'title': title,
    'description': 'A test event description',
    'organizer': 'Test Organizer',
    'venue': {
      'name': 'Test Venue',
      'address': {
        'street': 'Test Street 1',
        'city': 'Prague',
        'postalCode': '110 00',
        'country': 'Czech Republic',
      },
      'description': 'A test venue',
      'latitude': 50.08,
      'longitude': 14.42,
    },
    'startTime': '2025-03-01T19:00:00.000Z',
    'endTime': '2025-03-01T23:00:00.000Z',
    'duration': 14400,
    'dances': ['salsa', 'bachata'],
    'info': [
      {'type': 'price', 'key': 'Entry', 'value': '150 CZK'},
    ],
    'parts': [
      {
        'name': 'Workshop',
        'type': 'workshop',
        'startTime': '2025-03-01T19:00:00.000Z',
        'endTime': '2025-03-01T20:00:00.000Z',
        'lectors': ['Instructor A'],
      },
    ],
    'isFavorite': isFavorite,
    'isPast': isPast,
  };
}
