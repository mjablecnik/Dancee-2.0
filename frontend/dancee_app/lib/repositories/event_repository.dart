import '../models/event.dart';
import '../models/venue.dart';
import '../models/address.dart';
import '../models/event_info.dart';
import '../models/event_part.dart';

/// Repository for managing event data.
///
/// This repository provides access to event data using hardcoded data initially.
/// All methods return Future types to support future async API calls without
/// requiring changes to the UI code.
///
/// The repository maintains in-memory state for the current session, allowing
/// favorite status to be toggled and persisted during the app's lifetime.
class EventRepository {
  // In-memory storage of events
  List<Event> _events = [];

  /// Creates an EventRepository and initializes it with hardcoded event data.
  EventRepository() {
    _initializeEvents();
  }

  /// Initializes the repository with hardcoded event data.
  ///
  /// This includes events from both EventListScreen and FavoritesScreen.
  /// In the future, this will be replaced with REST API calls.
  void _initializeEvents() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final inTwoDays = today.add(const Duration(days: 2));
    final nextWeek = today.add(const Duration(days: 7));
    final nextWeekPlus1 = today.add(const Duration(days: 8));
    final nextWeekPlus2 = today.add(const Duration(days: 9));
    final nextWeekPlus3 = today.add(const Duration(days: 10));
    final twoWeeksAgo = today.subtract(const Duration(days: 14));
    final threeWeeksAgo = today.subtract(const Duration(days: 21));

    _events = [
      // Today events from EventListScreen
      Event(
        id: '1',
        title: 'Salsa Social Night',
        description: 'Join us for an amazing night of Salsa, Bachata, and Kizomba dancing!',
        organizer: 'Prague Dance Events',
        venue: Venue(
          name: 'Lucerna Music Bar',
          address: Address(
            street: 'Vodičkova 36',
            city: 'Prague',
            postalCode: '110 00',
            country: 'Czech Republic',
          ),
          description: 'Historic music venue in the heart of Prague',
          latitude: 50.0813,
          longitude: 14.4253,
        ),
        startTime: today.add(const Duration(hours: 20)),
        endTime: today.add(const Duration(hours: 26)), // 2:00 next day
        duration: const Duration(hours: 6),
        dances: ['Salsa', 'Bachata', 'Kizomba'],
        info: [
          const EventInfo(
            type: EventInfoType.price,
            key: 'Entry Fee',
            value: '150 Kč',
          ),
          const EventInfo(
            type: EventInfoType.url,
            key: 'Facebook Event',
            value: 'https://facebook.com/events/salsa-social-night',
          ),
          const EventInfo(
            type: EventInfoType.text,
            key: 'Dress Code',
            value: 'Casual',
          ),
        ],
        parts: [
          EventPart(
            name: 'Social Dancing',
            description: 'Open social dancing with DJ',
            type: EventPartType.party,
            startTime: today.add(const Duration(hours: 20)),
            endTime: today.add(const Duration(hours: 26)),
            djs: ['DJ Carlos', 'DJ Maria'],
          ),
        ],
        isFavorite: false,
        isPast: false,
      ),
      Event(
        id: '2',
        title: 'Bachata Tuesdays',
        description: 'Weekly Bachata social with sensual styling workshop',
        organizer: 'Dance Arena Team',
        venue: Venue(
          name: 'Dance Arena Prague',
          address: Address(
            street: 'Komunardů 30',
            city: 'Prague',
            postalCode: '170 00',
            country: 'Czech Republic',
          ),
          description: 'Modern dance studio with professional floor',
          latitude: 50.1025,
          longitude: 14.4378,
        ),
        startTime: today.add(const Duration(hours: 19, minutes: 30)),
        endTime: today.add(const Duration(hours: 23, minutes: 30)),
        duration: const Duration(hours: 4),
        dances: ['Bachata', 'Sensual'],
        info: [
          const EventInfo(
            type: EventInfoType.price,
            key: 'Full Event',
            value: '100 Kč',
          ),
          const EventInfo(
            type: EventInfoType.price,
            key: 'Workshop Only',
            value: '50 Kč',
          ),
          const EventInfo(
            type: EventInfoType.price,
            key: 'Party Only',
            value: '80 Kč',
          ),
        ],
        parts: [
          EventPart(
            name: 'Sensual Styling Workshop',
            description: 'Learn sensual bachata styling techniques',
            type: EventPartType.workshop,
            startTime: today.add(const Duration(hours: 19, minutes: 30)),
            endTime: today.add(const Duration(hours: 21)),
            lectors: ['Anna Martinez', 'Carlos Rodriguez'],
          ),
          EventPart(
            name: 'Bachata Social',
            description: 'Social dancing with live DJ',
            type: EventPartType.party,
            startTime: today.add(const Duration(hours: 21)),
            endTime: today.add(const Duration(hours: 23, minutes: 30)),
            djs: ['DJ Bachata King'],
          ),
        ],
        isFavorite: true,
        isPast: false,
      ),
      Event(
        id: '3',
        title: 'Zouk Workshop & Party',
        description: 'Brazilian Zouk workshop followed by social dancing',
        organizer: 'Studio Tance',
        venue: Venue(
          name: 'Studio Tance',
          address: Address(
            street: 'Vinohradská 48',
            city: 'Prague',
            postalCode: '120 00',
            country: 'Czech Republic',
          ),
          description: 'Spacious dance studio in Vinohrady',
          latitude: 50.0755,
          longitude: 14.4378,
        ),
        startTime: today.add(const Duration(hours: 18)),
        endTime: today.add(const Duration(hours: 22)),
        duration: const Duration(hours: 4),
        dances: ['Zouk', 'Brazilian Zouk'],
        info: [
          const EventInfo(
            type: EventInfoType.price,
            key: 'Entry Fee',
            value: '120 Kč',
          ),
        ],
        parts: [
          EventPart(
            name: 'Zouk Workshop',
            description: 'Learn Brazilian Zouk basics',
            type: EventPartType.workshop,
            startTime: today.add(const Duration(hours: 18)),
            endTime: today.add(const Duration(hours: 19, minutes: 30)),
            lectors: ['Pedro Silva', 'Ana Costa'],
          ),
          EventPart(
            name: 'Zouk Party',
            description: 'Social dancing with DJ',
            type: EventPartType.party,
            startTime: today.add(const Duration(hours: 19, minutes: 30)),
            endTime: today.add(const Duration(hours: 22)),
            djs: ['DJ Zouk Master'],
          ),
        ],
        isFavorite: false,
        isPast: false,
      ),
      // Tomorrow events from EventListScreen
      Event(
        id: '4',
        title: 'Kizomba Wednesday',
        description: 'Kizomba, Urban Kiz, and Tarraxo night',
        organizer: 'Club Lavka',
        venue: Venue(
          name: 'Club Lavka',
          address: Address(
            street: 'Novotného lávka 1',
            city: 'Prague',
            postalCode: '110 00',
            country: 'Czech Republic',
          ),
          description: 'Riverside club with amazing views',
          latitude: 50.0865,
          longitude: 14.4114,
        ),
        startTime: tomorrow.add(const Duration(hours: 20)),
        endTime: tomorrow.add(const Duration(hours: 25)), // 1:00 next day
        duration: const Duration(hours: 5),
        dances: ['Kizomba', 'Urban Kiz', 'Tarraxo'],
        info: [
          const EventInfo(
            type: EventInfoType.price,
            key: 'Entry Fee',
            value: '150 Kč',
          ),
        ],
        parts: [
          EventPart(
            name: 'Kizomba Night',
            description: 'Social dancing with multiple DJs',
            type: EventPartType.party,
            startTime: tomorrow.add(const Duration(hours: 20)),
            endTime: tomorrow.add(const Duration(hours: 25)),
            djs: ['DJ Kizomba Pro', 'DJ Urban'],
          ),
        ],
        isFavorite: false,
        isPast: false,
      ),
      Event(
        id: '5',
        title: 'Tango Practica',
        description: 'Argentine Tango practice session',
        organizer: 'Café Milonga',
        venue: Venue(
          name: 'Café Milonga',
          address: Address(
            street: 'Újezd 18',
            city: 'Prague',
            postalCode: '118 00',
            country: 'Czech Republic',
          ),
          description: 'Cozy café with tango atmosphere',
          latitude: 50.0819,
          longitude: 14.4058,
        ),
        startTime: tomorrow.add(const Duration(hours: 19)),
        endTime: tomorrow.add(const Duration(hours: 22)),
        duration: const Duration(hours: 3),
        dances: ['Tango', 'Argentine Tango'],
        info: [
          const EventInfo(
            type: EventInfoType.price,
            key: 'Entry Fee',
            value: '100 Kč',
          ),
        ],
        parts: [
          EventPart(
            name: 'Tango Practica',
            description: 'Practice session for all levels',
            type: EventPartType.party,
            startTime: tomorrow.add(const Duration(hours: 19)),
            endTime: tomorrow.add(const Duration(hours: 22)),
            djs: ['DJ Tango Maestro'],
          ),
        ],
        isFavorite: true,
        isPast: false,
      ),
      // This week events from EventListScreen
      Event(
        id: '6',
        title: 'Latin Mix Party',
        description: 'Mix of Salsa, Bachata, and Merengue',
        organizer: 'Cross Club',
        venue: Venue(
          name: 'Cross Club',
          address: Address(
            street: 'Plynární 23',
            city: 'Prague',
            postalCode: '170 00',
            country: 'Czech Republic',
          ),
          description: 'Industrial-style club with unique atmosphere',
          latitude: 50.1025,
          longitude: 14.4500,
        ),
        startTime: nextWeek.add(const Duration(hours: 21)),
        endTime: nextWeek.add(const Duration(hours: 27)), // 3:00 next day
        duration: const Duration(hours: 6),
        dances: ['Salsa', 'Bachata', 'Merengue'],
        info: [
          const EventInfo(
            type: EventInfoType.price,
            key: 'Entry Fee',
            value: '180 Kč',
          ),
        ],
        parts: [
          EventPart(
            name: 'Latin Party',
            description: 'All night Latin dancing',
            type: EventPartType.party,
            startTime: nextWeek.add(const Duration(hours: 21)),
            endTime: nextWeek.add(const Duration(hours: 27)),
            djs: ['DJ Latino', 'DJ Salsa King'],
          ),
        ],
        isFavorite: false,
        isPast: false,
      ),
      // Additional favorite events from FavoritesScreen
      Event(
        id: '7',
        title: 'Salsa & Bachata Night Prague',
        description: 'Amazing night of Salsa, Bachata, and Kizomba',
        organizer: 'Dance Club Central',
        venue: Venue(
          name: 'Dance Club Central',
          address: Address(
            street: 'Národní 25',
            city: 'Prague',
            postalCode: '110 00',
            country: 'Czech Republic',
          ),
          description: 'Central dance club with great atmosphere',
          latitude: 50.0820,
          longitude: 14.4190,
        ),
        startTime: today.add(const Duration(hours: 20)),
        endTime: today.add(const Duration(hours: 26)),
        duration: const Duration(hours: 6),
        dances: ['Salsa', 'Bachata', 'Kizomba'],
        info: [
          const EventInfo(
            type: EventInfoType.price,
            key: 'Entry Fee',
            value: '150 Kč',
          ),
        ],
        parts: [
          EventPart(
            name: 'Social Dancing',
            description: 'All night social dancing',
            type: EventPartType.party,
            startTime: today.add(const Duration(hours: 20)),
            endTime: today.add(const Duration(hours: 26)),
            djs: ['DJ Central'],
          ),
        ],
        isFavorite: true,
        isPast: false,
        badge: 'TODAY',
      ),
      Event(
        id: '8',
        title: 'Bachata Sensual Workshop',
        description: 'Learn sensual bachata techniques',
        organizer: 'Studio Rytmus',
        venue: Venue(
          name: 'Studio Rytmus',
          address: Address(
            street: 'Korunní 2',
            city: 'Prague',
            postalCode: '120 00',
            country: 'Czech Republic',
          ),
          description: 'Professional dance studio',
          latitude: 50.0750,
          longitude: 14.4400,
        ),
        startTime: inTwoDays.add(const Duration(hours: 18)),
        endTime: inTwoDays.add(const Duration(hours: 21)),
        duration: const Duration(hours: 3),
        dances: ['Bachata', 'Sensual'],
        info: [
          const EventInfo(
            type: EventInfoType.price,
            key: 'Workshop Fee',
            value: '200 Kč',
          ),
        ],
        parts: [
          EventPart(
            name: 'Sensual Workshop',
            description: 'Advanced sensual bachata techniques',
            type: EventPartType.workshop,
            startTime: inTwoDays.add(const Duration(hours: 18)),
            endTime: inTwoDays.add(const Duration(hours: 21)),
            lectors: ['Maria Santos', 'Juan Lopez'],
          ),
        ],
        isFavorite: true,
        isPast: false,
        badge: 'IN 2 DAYS',
      ),
      Event(
        id: '9',
        title: 'Kizomba Fusion Party',
        description: 'Kizomba, Urban Kiz, and Tarraxo fusion night',
        organizer: 'Karlín Hall',
        venue: Venue(
          name: 'Karlín Hall',
          address: Address(
            street: 'Thámova 11',
            city: 'Prague',
            postalCode: '186 00',
            country: 'Czech Republic',
          ),
          description: 'Large hall perfect for dancing',
          latitude: 50.0950,
          longitude: 14.4500,
        ),
        startTime: nextWeekPlus1.add(const Duration(hours: 21)),
        endTime: nextWeekPlus1.add(const Duration(hours: 26)),
        duration: const Duration(hours: 5),
        dances: ['Kizomba', 'Urban Kiz', 'Tarraxo'],
        info: [
          const EventInfo(
            type: EventInfoType.price,
            key: 'Entry Fee',
            value: '180 Kč',
          ),
        ],
        parts: [
          EventPart(
            name: 'Fusion Party',
            description: 'All styles of Kizomba',
            type: EventPartType.party,
            startTime: nextWeekPlus1.add(const Duration(hours: 21)),
            endTime: nextWeekPlus1.add(const Duration(hours: 26)),
            djs: ['DJ Fusion', 'DJ Kiz'],
          ),
        ],
        isFavorite: true,
        isPast: false,
      ),
      Event(
        id: '10',
        title: 'Zouk Social Dance',
        description: 'Brazilian Zouk social dancing evening',
        organizer: 'Dance Factory',
        venue: Venue(
          name: 'Dance Factory',
          address: Address(
            street: 'Wuchterlova 5',
            city: 'Prague',
            postalCode: '160 00',
            country: 'Czech Republic',
          ),
          description: 'Modern dance factory space',
          latitude: 50.0800,
          longitude: 14.4100,
        ),
        startTime: nextWeekPlus2.add(const Duration(hours: 19, minutes: 30)),
        endTime: nextWeekPlus2.add(const Duration(hours: 23)),
        duration: const Duration(hours: 3, minutes: 30),
        dances: ['Zouk', 'Brazilian Zouk'],
        info: [
          const EventInfo(
            type: EventInfoType.price,
            key: 'Entry Fee',
            value: '120 Kč',
          ),
        ],
        parts: [
          EventPart(
            name: 'Zouk Social',
            description: 'Social dancing with DJ',
            type: EventPartType.party,
            startTime: nextWeekPlus2.add(const Duration(hours: 19, minutes: 30)),
            endTime: nextWeekPlus2.add(const Duration(hours: 23)),
            djs: ['DJ Zouk Vibes'],
          ),
        ],
        isFavorite: true,
        isPast: false,
      ),
      Event(
        id: '11',
        title: 'Salsa On2 Masterclass',
        description: 'Advanced Salsa On2 techniques masterclass',
        organizer: 'Dance Club Central',
        venue: Venue(
          name: 'Dance Club Central',
          address: Address(
            street: 'Národní 25',
            city: 'Prague',
            postalCode: '110 00',
            country: 'Czech Republic',
          ),
          description: 'Central dance club with great atmosphere',
          latitude: 50.0820,
          longitude: 14.4190,
        ),
        startTime: nextWeekPlus3.add(const Duration(hours: 16)),
        endTime: nextWeekPlus3.add(const Duration(hours: 19)),
        duration: const Duration(hours: 3),
        dances: ['Salsa', 'On2'],
        info: [
          const EventInfo(
            type: EventInfoType.price,
            key: 'Masterclass Fee',
            value: '300 Kč',
          ),
        ],
        parts: [
          EventPart(
            name: 'On2 Masterclass',
            description: 'Advanced techniques for Salsa On2',
            type: EventPartType.workshop,
            startTime: nextWeekPlus3.add(const Duration(hours: 16)),
            endTime: nextWeekPlus3.add(const Duration(hours: 19)),
            lectors: ['Eddie Torres Jr.', 'Griselle Ponce'],
          ),
        ],
        isFavorite: true,
        isPast: false,
      ),
      Event(
        id: '12',
        title: 'Samba de Gafieira Evening',
        description: 'Brazilian Samba de Gafieira social dancing',
        organizer: 'Rio Dance Studio',
        venue: Venue(
          name: 'Rio Dance Studio',
          address: Address(
            street: 'Italská 12',
            city: 'Prague',
            postalCode: '120 00',
            country: 'Czech Republic',
          ),
          description: 'Brazilian dance studio',
          latitude: 50.0730,
          longitude: 14.4350,
        ),
        startTime: nextWeekPlus3.add(const Duration(days: 4, hours: 20)),
        endTime: nextWeekPlus3.add(const Duration(days: 4, hours: 24)),
        duration: const Duration(hours: 4),
        dances: ['Samba', 'Gafieira'],
        info: [
          const EventInfo(
            type: EventInfoType.price,
            key: 'Entry Fee',
            value: '150 Kč',
          ),
        ],
        parts: [
          EventPart(
            name: 'Samba Evening',
            description: 'Social Samba de Gafieira dancing',
            type: EventPartType.party,
            startTime: nextWeekPlus3.add(const Duration(days: 4, hours: 20)),
            endTime: nextWeekPlus3.add(const Duration(days: 4, hours: 24)),
            djs: ['DJ Samba Brasil'],
          ),
        ],
        isFavorite: true,
        isPast: false,
      ),
      Event(
        id: '13',
        title: 'Latin Night Mix',
        description: 'Mix of Salsa, Bachata, Merengue, and Reggaeton',
        organizer: 'Lucerna Music Bar',
        venue: Venue(
          name: 'Lucerna Music Bar',
          address: Address(
            street: 'Vodičkova 36',
            city: 'Prague',
            postalCode: '110 00',
            country: 'Czech Republic',
          ),
          description: 'Historic music venue in the heart of Prague',
          latitude: 50.0813,
          longitude: 14.4253,
        ),
        startTime: nextWeekPlus3.add(const Duration(days: 5, hours: 22)),
        endTime: nextWeekPlus3.add(const Duration(days: 6, hours: 3)),
        duration: const Duration(hours: 5),
        dances: ['Salsa', 'Bachata', 'Merengue', 'Reggaeton'],
        info: [
          const EventInfo(
            type: EventInfoType.price,
            key: 'Entry Fee',
            value: '200 Kč',
          ),
        ],
        parts: [
          EventPart(
            name: 'Latin Mix Party',
            description: 'All Latin styles in one night',
            type: EventPartType.party,
            startTime: nextWeekPlus3.add(const Duration(days: 5, hours: 22)),
            endTime: nextWeekPlus3.add(const Duration(days: 6, hours: 3)),
            djs: ['DJ Latino Mix', 'DJ Reggaeton'],
          ),
        ],
        isFavorite: true,
        isPast: false,
      ),
      Event(
        id: '14',
        title: 'Bachata Romántica Night',
        description: 'Romantic Bachata evening with traditional style',
        organizer: 'Dance Club Central',
        venue: Venue(
          name: 'Dance Club Central',
          address: Address(
            street: 'Národní 25',
            city: 'Prague',
            postalCode: '110 00',
            country: 'Czech Republic',
          ),
          description: 'Central dance club with great atmosphere',
          latitude: 50.0820,
          longitude: 14.4190,
        ),
        startTime: nextWeekPlus3.add(const Duration(days: 6, hours: 20, minutes: 30)),
        endTime: nextWeekPlus3.add(const Duration(days: 7, hours: 1)),
        duration: const Duration(hours: 4, minutes: 30),
        dances: ['Bachata', 'Romántica'],
        info: [
          const EventInfo(
            type: EventInfoType.price,
            key: 'Entry Fee',
            value: '150 Kč',
          ),
        ],
        parts: [
          EventPart(
            name: 'Romántica Night',
            description: 'Traditional romantic Bachata',
            type: EventPartType.party,
            startTime: nextWeekPlus3.add(const Duration(days: 6, hours: 20, minutes: 30)),
            endTime: nextWeekPlus3.add(const Duration(days: 7, hours: 1)),
            djs: ['DJ Bachata Romántica'],
          ),
        ],
        isFavorite: true,
        isPast: false,
      ),
      // Past events from FavoritesScreen
      Event(
        id: '15',
        title: 'Salsa Cubana Workshop',
        description: 'Traditional Cuban Salsa workshop',
        organizer: 'Studio Rytmus',
        venue: Venue(
          name: 'Studio Rytmus',
          address: Address(
            street: 'Korunní 2',
            city: 'Prague',
            postalCode: '120 00',
            country: 'Czech Republic',
          ),
          description: 'Professional dance studio',
          latitude: 50.0750,
          longitude: 14.4400,
        ),
        startTime: twoWeeksAgo.add(const Duration(hours: 17)),
        endTime: twoWeeksAgo.add(const Duration(hours: 20)),
        duration: const Duration(hours: 3),
        dances: ['Salsa', 'Cubana'],
        info: [
          const EventInfo(
            type: EventInfoType.price,
            key: 'Workshop Fee',
            value: '250 Kč',
          ),
        ],
        parts: [
          EventPart(
            name: 'Cubana Workshop',
            description: 'Learn traditional Cuban Salsa',
            type: EventPartType.workshop,
            startTime: twoWeeksAgo.add(const Duration(hours: 17)),
            endTime: twoWeeksAgo.add(const Duration(hours: 20)),
            lectors: ['Carlos Havana', 'Maria Cuba'],
          ),
        ],
        isFavorite: true,
        isPast: true,
        badge: 'FINISHED',
      ),
      Event(
        id: '16',
        title: 'Kizomba Ladies Styling',
        description: 'Ladies styling workshop for Kizomba',
        organizer: 'Karlín Hall',
        venue: Venue(
          name: 'Karlín Hall',
          address: Address(
            street: 'Thámova 11',
            city: 'Prague',
            postalCode: '186 00',
            country: 'Czech Republic',
          ),
          description: 'Large hall perfect for dancing',
          latitude: 50.0950,
          longitude: 14.4500,
        ),
        startTime: threeWeeksAgo.add(const Duration(hours: 15)),
        endTime: threeWeeksAgo.add(const Duration(hours: 18)),
        duration: const Duration(hours: 3),
        dances: ['Kizomba', 'Ladies'],
        info: [
          const EventInfo(
            type: EventInfoType.price,
            key: 'Workshop Fee',
            value: '200 Kč',
          ),
        ],
        parts: [
          EventPart(
            name: 'Ladies Styling',
            description: 'Styling techniques for ladies',
            type: EventPartType.workshop,
            startTime: threeWeeksAgo.add(const Duration(hours: 15)),
            endTime: threeWeeksAgo.add(const Duration(hours: 18)),
            lectors: ['Isabella Kiz', 'Sofia Dance'],
          ),
        ],
        isFavorite: true,
        isPast: true,
        badge: 'FINISHED',
      ),
    ];
  }

  /// Returns all events.
  ///
  /// This method returns a Future to support future async API calls.
  /// Currently simulates async operation with a small delay.
  Future<List<Event>> getAllEvents() async {
    // Simulate async operation for future API compatibility
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_events);
  }

  /// Returns only favorite events.
  ///
  /// Filters events where isFavorite is true.
  Future<List<Event>> getFavoriteEvents() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _events.where((event) => event.isFavorite).toList();
  }

  /// Returns events for a specific date.
  ///
  /// Compares the date portion of event startTime with the provided date.
  Future<List<Event>> getEventsByDate(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final targetDate = DateTime(date.year, date.month, date.day);
    return _events.where((event) {
      final eventDate = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      return eventDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  /// Toggles the favorite status of an event.
  ///
  /// Updates the in-memory event state by creating a new event with
  /// the opposite favorite status.
  Future<void> toggleFavorite(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final index = _events.indexWhere((event) => event.id == eventId);
    if (index != -1) {
      _events[index] = _events[index].copyWith(
        isFavorite: !_events[index].isFavorite,
      );
    }
  }

  /// Searches events by query string.
  ///
  /// Performs case-insensitive search on event title, venue name, and description.
  Future<List<Event>> searchEvents(String query) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (query.isEmpty) {
      return List.unmodifiable(_events);
    }
    
    final lowerQuery = query.toLowerCase();
    return _events.where((event) =>
      event.title.toLowerCase().contains(lowerQuery) ||
      event.venue.name.toLowerCase().contains(lowerQuery) ||
      event.description.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  /// Filters events by criteria.
  ///
  /// Supports filtering by:
  /// - dances: `List<String>` - filters events that include any of the specified dances
  /// - isPast: `bool` - filters events by past status
  /// - dateRange: `Map<String, DateTime>` with 'start' and 'end' keys
  ///
  /// Multiple criteria can be combined.
  Future<List<Event>> filterEvents(Map<String, dynamic> criteria) async {
    await Future.delayed(const Duration(milliseconds: 100));
    var filtered = _events;
    
    if (criteria.containsKey('dances')) {
      final dances = criteria['dances'] as List<String>;
      filtered = filtered.where((event) =>
        event.dances.any((dance) => dances.contains(dance))
      ).toList();
    }
    
    if (criteria.containsKey('isPast')) {
      final isPast = criteria['isPast'] as bool;
      filtered = filtered.where((event) => event.isPast == isPast).toList();
    }
    
    if (criteria.containsKey('dateRange')) {
      final range = criteria['dateRange'] as Map<String, DateTime>;
      final start = range['start'];
      final end = range['end'];
      if (start != null && end != null) {
        filtered = filtered.where((event) =>
          event.startTime.isAfter(start) && event.startTime.isBefore(end)
        ).toList();
      }
    }
    
    return filtered;
  }
}
