import 'package:mocktail/mocktail.dart';
import 'package:dancee_app/core/clients.dart';
import 'package:dancee_app/features/events/data/event_repository.dart';
import 'package:dancee_app/features/events/logic/event_list.dart';
import 'package:dancee_app/features/events/data/entities.dart';

// =============================================================================
// Mock classes
// =============================================================================

class MockApiClient extends Mock implements ApiClient {}

class MockEventRepository extends Mock implements EventRepository {}

class MockEventListCubit extends Mock implements EventListCubit {}

// =============================================================================
// Factory helpers
// =============================================================================

/// Creates a test Event with sensible defaults.
///
/// Override any parameter to customise the event for your test case.
Event createTestEvent({
  String id = '1',
  String title = 'Test Event',
  String description = 'A test event description',
  String organizer = 'Test Organizer',
  String venueName = 'Test Venue',
  DateTime? startTime,
  bool isFavorite = false,
  bool isPast = false,
}) {
  final start = startTime ?? DateTime.now().add(const Duration(hours: 2));
  return Event(
    id: id,
    title: title,
    description: description,
    organizer: organizer,
    venue: Venue(
      name: venueName,
      address: const Address(
        street: 'Test Street 1',
        city: 'Prague',
        postalCode: '110 00',
        country: 'Czech Republic',
      ),
      description: 'A test venue',
      latitude: 50.08,
      longitude: 14.42,
    ),
    startTime: start,
    endTime: start.add(const Duration(hours: 4)),
    duration: const Duration(hours: 4),
    dances: const ['salsa', 'bachata'],
    info: const [],
    parts: const [],
    isFavorite: isFavorite,
    isPast: isPast,
  );
}
