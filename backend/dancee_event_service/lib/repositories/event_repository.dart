import 'package:dancee_shared/dancee_shared.dart';

/// Repository for managing dance events using in-memory storage.
class EventRepository {
  final List<Event> _events = [];

  EventRepository() {
    _initializeSampleData();
  }

  Future<List<Event>> getAllEvents() async {
    return List.unmodifiable(_events);
  }

  Future<bool> eventExists(String eventId) async {
    return _events.any((event) => event.id == eventId);
  }

  Future<Event?> getEventById(String eventId) async {
    try {
      return _events.firstWhere((event) => event.id == eventId);
    } catch (e) {
      return null;
    }
  }
  void _initializeSampleData() {
    final now = DateTime.now();
    _events.add(Event(
      id: 'event-001',
      title: 'Prague Salsa Night',
      description:
          'Join us for an amazing night of Salsa dancing! Live band performance and social dancing until late.',
      organizer: 'Prague Salsa Club',
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
        longitude: 14.4258,
      ),
      startTime: now.add(Duration(days: 5, hours: 20)),
      endTime: now.add(Duration(days: 6, hours: 2)),
      duration: Duration(hours: 6),
      dances: ['Salsa', 'Bachata'],
      info: [
        EventInfo(
          type: EventInfoType.price,
          key: 'Entry Fee',
          value: '200 Kč',
        ),
        EventInfo(
          type: EventInfoType.url,
          key: 'Facebook Event',
          value: 'https://facebook.com/events/salsa-night',
        ),
      ],
      parts: [
        EventPart(
          name: 'Social Dancing',
          description: 'Open social dancing with live band',
          type: EventPartType.party,
          startTime: now.add(Duration(days: 5, hours: 20)),
          endTime: now.add(Duration(days: 6, hours: 2)),
          djs: ['DJ Carlos', 'DJ Maria'],
        ),
      ],
    ));

    _events.add(Event(
      id: 'event-002',
      title: 'Bachata Sensual Workshop & Party',
      description:
          'Learn Bachata Sensual with international instructors followed by a social party.',
      organizer: 'Bachata Prague',
      venue: Venue(
        name: 'Dance Studio XL',
        address: Address(
          street: 'Vinohradská 48',
          city: 'Prague',
          postalCode: '120 00',
          country: 'Czech Republic',
        ),
        description: 'Modern dance studio with professional floor',
        latitude: 50.0755,
        longitude: 14.4378,
      ),
      startTime: now.add(Duration(days: 7, hours: 19, minutes: 30)),
      endTime: now.add(Duration(days: 7, hours: 23, minutes: 30)),
      duration: Duration(hours: 4),
      dances: ['Bachata'],
      info: [
        EventInfo(
          type: EventInfoType.price,
          key: 'Workshop + Party',
          value: '350 Kč',
        ),
        EventInfo(
          type: EventInfoType.price,
          key: 'Party Only',
          value: '150 Kč',
        ),
        EventInfo(
          type: EventInfoType.text,
          key: 'Level',
          value: 'Intermediate',
        ),
      ],
      parts: [
        EventPart(
          name: 'Bachata Sensual Workshop',
          description: 'Intermediate level workshop focusing on body movement',
          type: EventPartType.workshop,
          startTime: now.add(Duration(days: 7, hours: 19, minutes: 30)),
          endTime: now.add(Duration(days: 7, hours: 21)),
          lectors: ['Carlos & Maria', 'David & Sofia'],
        ),
        EventPart(
          name: 'Social Party',
          description: 'Social dancing with the best Bachata music',
          type: EventPartType.party,
          startTime: now.add(Duration(days: 7, hours: 21)),
          endTime: now.add(Duration(days: 7, hours: 23, minutes: 30)),
          djs: ['DJ Romeo'],
        ),
      ],
    ));

    _events.add(Event(
      id: 'event-003',
      title: 'Prague Kizomba Festival 2024',
      description:
          'Three-day Kizomba festival with international instructors, workshops, and parties.',
      organizer: 'Kizomba Czech',
      venue: Venue(
        name: 'Hotel Olympik Congress',
        address: Address(
          street: 'Sokolovská 138',
          city: 'Prague',
          postalCode: '186 00',
          country: 'Czech Republic',
        ),
        description: 'Large conference hotel with multiple dance halls',
        latitude: 50.1008,
        longitude: 14.4547,
      ),
      startTime: now.add(Duration(days: 14)),
      endTime: now.add(Duration(days: 17)),
      duration: Duration(days: 3),
      dances: ['Kizomba', 'Urban Kiz', 'Semba'],
      info: [
        EventInfo(
          type: EventInfoType.price,
          key: 'Full Pass',
          value: '2500 Kč',
        ),
        EventInfo(
          type: EventInfoType.price,
          key: 'Party Pass',
          value: '1200 Kč',
        ),
        EventInfo(
          type: EventInfoType.url,
          key: 'Registration',
          value: 'https://kizombafestival.cz',
        ),
      ],
      parts: [
        EventPart(
          name: 'Friday Night Party',
          type: EventPartType.party,
          startTime: now.add(Duration(days: 14, hours: 21)),
          endTime: now.add(Duration(days: 15, hours: 3)),
          djs: ['DJ Mika', 'DJ Zé'],
        ),
      ],
    ));

    _events.add(Event(
      id: 'event-004',
      title: 'Swing Dance Open Lesson',
      description:
          'Free open lesson for beginners! Learn the basics of Lindy Hop and Charleston.',
      organizer: 'Prague Swing Society',
      venue: Venue(
        name: 'Café V lese',
        address: Address(
          street: 'Krymská 12',
          city: 'Prague',
          postalCode: '101 00',
          country: 'Czech Republic',
        ),
        description: 'Cozy café with dance floor',
        latitude: 50.0719,
        longitude: 14.4503,
      ),
      startTime: now.add(Duration(days: 3, hours: 18)),
      endTime: now.add(Duration(days: 3, hours: 20)),
      duration: Duration(hours: 2),
      dances: ['Lindy Hop', 'Charleston'],
      info: [
        EventInfo(
          type: EventInfoType.price,
          key: 'Entry',
          value: 'Free',
        ),
        EventInfo(
          type: EventInfoType.text,
          key: 'Level',
          value: 'Beginners welcome',
        ),
      ],
      parts: [
        EventPart(
          name: 'Open Lesson',
          description: 'Introduction to Swing dancing',
          type: EventPartType.openLesson,
          startTime: now.add(Duration(days: 3, hours: 18)),
          endTime: now.add(Duration(days: 3, hours: 20)),
          lectors: ['Tom & Jerry'],
        ),
      ],
    ));

    _events.add(Event(
      id: 'event-005',
      title: 'Traditional Tango Milonga',
      description:
          'Traditional Argentine Tango milonga with live orchestra. Dress code: elegant.',
      organizer: 'Tango Prague',
      venue: Venue(
        name: 'Žofín Palace',
        address: Address(
          street: 'Slovanský ostrov 226',
          city: 'Prague',
          postalCode: '110 00',
          country: 'Czech Republic',
        ),
        description: 'Historic palace on an island in the Vltava river',
        latitude: 50.0794,
        longitude: 14.4133,
      ),
      startTime: now.add(Duration(days: 10, hours: 20)),
      endTime: now.add(Duration(days: 11, hours: 1)),
      duration: Duration(hours: 5),
      dances: ['Argentine Tango'],
      info: [
        EventInfo(
          type: EventInfoType.price,
          key: 'Entry Fee',
          value: '300 Kč',
        ),
        EventInfo(
          type: EventInfoType.text,
          key: 'Dress Code',
          value: 'Elegant attire required',
        ),
      ],
      parts: [
        EventPart(
          name: 'Milonga',
          description: 'Traditional tango social dancing',
          type: EventPartType.party,
          startTime: now.add(Duration(days: 10, hours: 20)),
          endTime: now.add(Duration(days: 11, hours: 1)),
          djs: ['DJ Osvaldo'],
        ),
      ],
    ));

    _events.add(Event(
      id: 'event-006',
      title: 'Brazilian Zouk Intensive Weekend',
      description:
          'Intensive weekend with multiple workshops covering all levels of Brazilian Zouk.',
      organizer: 'Zouk Prague',
      venue: Venue(
        name: 'Dance Arena',
        address: Address(
          street: 'Komunardů 30',
          city: 'Prague',
          postalCode: '170 00',
          country: 'Czech Republic',
        ),
        description: 'Large dance studio with sprung floor',
        latitude: 50.0989,
        longitude: 14.4531,
      ),
      startTime: now.add(Duration(days: 21, hours: 10)),
      endTime: now.add(Duration(days: 23, hours: 2)),
      duration: Duration(hours: 64),
      dances: ['Brazilian Zouk'],
      info: [
        EventInfo(
          type: EventInfoType.price,
          key: 'Full Weekend',
          value: '1800 Kč',
        ),
        EventInfo(
          type: EventInfoType.price,
          key: 'Single Day',
          value: '700 Kč',
        ),
        EventInfo(
          type: EventInfoType.url,
          key: 'Schedule',
          value: 'https://zoukprague.cz/intensive',
        ),
      ],
      parts: [
        EventPart(
          name: 'Saturday Workshops',
          description: 'Full day of workshops for all levels',
          type: EventPartType.workshop,
          startTime: now.add(Duration(days: 21, hours: 10)),
          endTime: now.add(Duration(days: 21, hours: 18)),
          lectors: ['Alex & Renata', 'Bruno & Camila'],
        ),
        EventPart(
          name: 'Saturday Night Party',
          type: EventPartType.party,
          startTime: now.add(Duration(days: 21, hours: 21)),
          endTime: now.add(Duration(days: 22, hours: 2)),
          djs: ['DJ Zouk Master'],
        ),
      ],
    ));

    _events.add(Event(
      id: 'event-007',
      title: 'Salsa & Bachata Fusion Night',
      description:
          'Mixed night with both Salsa and Bachata music. Perfect for dancers who love both styles!',
      organizer: 'Latin Dance Prague',
      venue: Venue(
        name: 'Club Mecca',
        address: Address(
          street: 'U Průhonu 3',
          city: 'Prague',
          postalCode: '170 00',
          country: 'Czech Republic',
        ),
        description: 'Popular nightclub with large dance floor',
        latitude: 50.1033,
        longitude: 14.4442,
      ),
      startTime: now.add(Duration(days: 2, hours: 21)),
      endTime: now.add(Duration(days: 3, hours: 3)),
      duration: Duration(hours: 6),
      dances: ['Salsa', 'Bachata'],
      info: [
        EventInfo(
          type: EventInfoType.price,
          key: 'Entry Fee',
          value: '150 Kč',
        ),
        EventInfo(
          type: EventInfoType.text,
          key: 'Dress Code',
          value: 'Casual',
        ),
      ],
      parts: [
        EventPart(
          name: 'Social Dancing',
          description: 'Mixed Salsa and Bachata music all night',
          type: EventPartType.party,
          startTime: now.add(Duration(days: 2, hours: 21)),
          endTime: now.add(Duration(days: 3, hours: 3)),
          djs: ['DJ Latino', 'DJ Tropical'],
        ),
      ],
    ));

    _events.add(Event(
      id: 'event-008',
      title: 'West Coast Swing Beginner Workshop',
      description:
          'Introduction to West Coast Swing for complete beginners. No partner needed!',
      organizer: 'WCS Prague',
      venue: Venue(
        name: 'Studio Tančírna',
        address: Address(
          street: 'Blanická 25',
          city: 'Prague',
          postalCode: '120 00',
          country: 'Czech Republic',
        ),
        description: 'Professional dance studio in Vinohrady',
        latitude: 50.0742,
        longitude: 14.4411,
      ),
      startTime: now.add(Duration(days: 8, hours: 19)),
      endTime: now.add(Duration(days: 8, hours: 21)),
      duration: Duration(hours: 2),
      dances: ['West Coast Swing'],
      info: [
        EventInfo(
          type: EventInfoType.price,
          key: 'Workshop Fee',
          value: '250 Kč',
        ),
        EventInfo(
          type: EventInfoType.text,
          key: 'Level',
          value: 'Absolute beginners',
        ),
        EventInfo(
          type: EventInfoType.text,
          key: 'Partner',
          value: 'No partner needed',
        ),
      ],
      parts: [
        EventPart(
          name: 'Beginner Workshop',
          description: 'Learn the basics of West Coast Swing',
          type: EventPartType.workshop,
          startTime: now.add(Duration(days: 8, hours: 19)),
          endTime: now.add(Duration(days: 8, hours: 21)),
          lectors: ['Mike & Sarah'],
        ),
      ],
    ));
  }
}
