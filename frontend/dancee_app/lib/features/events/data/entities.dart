import 'package:equatable/equatable.dart';

// ============================================================================
// Address
// ============================================================================

/// Represents a physical address with street, city, postal code, and country.
///
/// This is an immutable class that uses Equatable for value equality comparison.
class Address extends Equatable {
  /// The street address including house number
  final String street;

  /// The city name
  final String city;

  /// The postal code
  final String postalCode;

  /// The country name
  final String country;

  /// Creates an Address with all required fields.
  const Address({
    required this.street,
    required this.city,
    required this.postalCode,
    required this.country,
  });

  /// Returns the full address as a formatted string.
  ///
  /// Format: "street, postalCode city, country"
  /// Example: "Vodičkova 36, 110 00 Prague, Czech Republic"
  String get fullAddress => '$street, $postalCode $city, $country';

  /// Creates an Address from a JSON map.
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] as String,
      city: json['city'] as String,
      postalCode: json['postalCode'] as String,
      country: json['country'] as String,
    );
  }

  /// Converts this Address to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'postalCode': postalCode,
      'country': country,
    };
  }

  /// Creates a copy of this Address with the given fields replaced with new values.
  Address copyWith({
    String? street,
    String? city,
    String? postalCode,
    String? country,
  }) {
    return Address(
      street: street ?? this.street,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
    );
  }

  @override
  List<Object?> get props => [street, city, postalCode, country];
}

// ============================================================================
// Venue
// ============================================================================

/// Represents a venue where dance events take place.
///
/// This is an immutable class that uses Equatable for value equality comparison.
class Venue extends Equatable {
  /// The name of the venue
  final String name;

  /// The physical address of the venue
  final Address address;

  /// A description of the venue
  final String description;

  /// The latitude coordinate for map integration
  final double latitude;

  /// The longitude coordinate for map integration
  final double longitude;

  /// Creates a Venue with required and optional fields.
  const Venue({
    required this.name,
    required this.address,
    required this.description,
    required this.latitude,
    required this.longitude,
  });

  /// Creates a Venue from a JSON map.
  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      name: json['name'] as String,
      address: Address.fromJson(json['address'] as Map<String, dynamic>),
      description: json['description'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  /// Converts this Venue to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address.toJson(),
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Creates a copy of this Venue with the given fields replaced with new values.
  Venue copyWith({
    String? name,
    Address? address,
    String? description,
    double? latitude,
    double? longitude,
  }) {
    return Venue(
      name: name ?? this.name,
      address: address ?? this.address,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  List<Object?> get props => [name, address, description, latitude, longitude];
}

// ============================================================================
// EventInfo
// ============================================================================

/// The type of event information.
///
/// - [text]: Plain text information
/// - [url]: A clickable URL link
/// - [price]: Price information with currency
enum EventInfoType {
  text,
  url,
  price,
}

/// Represents additional information about an event.
///
/// This flexible key-value structure allows storing various types of information
/// such as URLs, prices, dress codes, etc. The type field determines how the
/// UI should render the information.
///
/// Examples:
/// - {"type": "url", "key": "Facebook Event", "value": "https://..."}
/// - {"type": "price", "key": "Entry Fee", "value": "150 Kč"}
/// - {"type": "text", "key": "Dress Code", "value": "Casual"}
///
/// This is an immutable class that uses Equatable for value equality comparison.
class EventInfo extends Equatable {
  /// The type of information (text, url, or price)
  final EventInfoType type;

  /// The label or key for this information
  final String key;

  /// The value of this information
  final String value;

  /// Creates an EventInfo with all required fields.
  const EventInfo({
    required this.type,
    required this.key,
    required this.value,
  });

  /// Creates an EventInfo from a JSON map.
  /// The type string is converted back to an EventInfoType enum.
  factory EventInfo.fromJson(Map<String, dynamic> json) {
    return EventInfo(
      type: EventInfoType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      key: json['key'] as String,
      value: json['value'] as String,
    );
  }

  /// Converts this EventInfo to a JSON map.
  /// The enum type is serialized as a string.
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'key': key,
      'value': value,
    };
  }

  /// Creates a copy of this EventInfo with the given fields replaced with new values.
  EventInfo copyWith({
    EventInfoType? type,
    String? key,
    String? value,
  }) {
    return EventInfo(
      type: type ?? this.type,
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }

  @override
  List<Object?> get props => [type, key, value];
}

// ============================================================================
// EventPart
// ============================================================================

/// The type of event part.
///
/// - [party]: A social dancing party
/// - [workshop]: A structured workshop or class
/// - [openLesson]: An open lesson for all levels
enum EventPartType {
  party,
  workshop,
  openLesson,
}

/// Represents a part of an event (e.g., workshop before party).
///
/// Events can consist of multiple parts with different schedules, instructors,
/// and DJs. For example, a typical event might have a workshop from 19:30-21:00
/// followed by a social party from 21:00-23:30.
///
/// This is an immutable class that uses Equatable for value equality comparison.
class EventPart extends Equatable {
  /// The name of this event part
  final String name;

  /// An optional description of this event part
  final String? description;

  /// The type of event part (party, workshop, or openLesson)
  final EventPartType type;

  /// The start time of this event part
  final DateTime startTime;

  /// The end time of this event part (optional)
  final DateTime? endTime;

  /// Optional list of instructors/lectors for workshops and lessons
  final List<String>? lectors;

  /// Optional list of DJs for parties
  final List<String>? djs;

  /// Creates an EventPart with required fields and optional fields.
  const EventPart({
    required this.name,
    this.description,
    required this.type,
    required this.startTime,
    this.endTime,
    this.lectors,
    this.djs,
  });

  /// Creates an EventPart from a JSON map.
  /// ISO 8601 date strings are converted back to DateTime objects.
  /// The type string is converted back to an EventPartType enum.
  factory EventPart.fromJson(Map<String, dynamic> json) {
    return EventPart(
      name: json['name'] as String,
      description: json['description'] as String?,
      type: EventPartType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      lectors: (json['lectors'] as List<dynamic>?)?.cast<String>(),
      djs: (json['djs'] as List<dynamic>?)?.cast<String>(),
    );
  }

  /// Converts this EventPart to a JSON map.
  /// Dates are serialized as ISO 8601 strings.
  /// The enum type is serialized as a string.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'type': type.name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'lectors': lectors,
      'djs': djs,
    };
  }

  /// Creates a copy of this EventPart with the given fields replaced with new values.
  EventPart copyWith({
    String? name,
    String? description,
    EventPartType? type,
    DateTime? startTime,
    DateTime? endTime,
    List<String>? lectors,
    List<String>? djs,
  }) {
    return EventPart(
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      lectors: lectors ?? this.lectors,
      djs: djs ?? this.djs,
    );
  }

  @override
  List<Object?> get props =>
      [name, description, type, startTime, endTime, lectors, djs];
}

// ============================================================================
// Event
// ============================================================================

/// Represents a dance event with all its details.
///
/// This is the main entity class for dance events in the application.
/// It contains all information about an event including venue, timing,
/// dance styles, additional information, and event parts.
///
/// This is an immutable class that uses Equatable for value equality comparison.
class Event extends Equatable {
  /// Unique identifier for the event
  final String id;

  /// The title of the event
  final String title;

  /// A detailed description of the event
  final String description;

  /// The name of the event organizer
  final String organizer;

  /// The venue where the event takes place
  final Venue venue;

  /// The start time of the event
  final DateTime startTime;

  /// The end time of the event (optional)
  final DateTime? endTime;

  /// The duration of the event (optional)
  final Duration? duration;

  /// List of dance styles featured at this event
  final List<String> dances;

  /// Additional information about the event (prices, URLs, etc.)
  final List<EventInfo> info;

  /// The parts/schedule of the event (workshops, parties, etc.)
  final List<EventPart> parts;

  /// Whether this event is marked as favorite by the user
  final bool isFavorite;

  /// Whether this event is in the past
  final bool isPast;

  /// Optional badge text (e.g., "TODAY", "IN 2 DAYS", "FINISHED")
  final String? badge;

  /// Creates an Event with all required fields and optional fields with defaults.
  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.organizer,
    required this.venue,
    required this.startTime,
    this.endTime,
    this.duration,
    required this.dances,
    this.info = const [],
    this.parts = const [],
    this.isFavorite = false,
    this.isPast = false,
    this.badge,
  });

  /// Creates an Event from a JSON map.
  /// ISO 8601 date strings are converted back to DateTime objects.
  /// Duration in seconds is converted back to a Duration object.
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      organizer: json['organizer'] as String,
      venue: Venue.fromJson(json['venue'] as Map<String, dynamic>),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      duration: json['duration'] != null ? Duration(seconds: json['duration'] as int) : null,
      dances: (json['dances'] as List<dynamic>?)?.cast<String>() ?? [],
      info: (json['info'] as List<dynamic>?)
          ?.map((i) => EventInfo.fromJson(i as Map<String, dynamic>))
          .toList() ?? [],
      parts: (json['parts'] as List<dynamic>?)
          ?.map((p) => EventPart.fromJson(p as Map<String, dynamic>))
          .toList() ?? [],
      isFavorite: json['isFavorite'] as bool? ?? false,
      isPast: json['isPast'] as bool? ?? false,
      badge: json['badge'] as String?,
    );
  }

  /// Converts this Event to a JSON map.
  /// Dates are serialized as ISO 8601 strings.
  /// Duration is serialized as total seconds (integer).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'organizer': organizer,
      'venue': venue.toJson(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'duration': duration?.inSeconds,
      'dances': dances,
      'info': info.map((i) => i.toJson()).toList(),
      'parts': parts.map((p) => p.toJson()).toList(),
      'isFavorite': isFavorite,
      'isPast': isPast,
      'badge': badge,
    };
  }

  /// Creates a copy of this Event with the given fields replaced with new values.
  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? organizer,
    Venue? venue,
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
    List<String>? dances,
    List<EventInfo>? info,
    List<EventPart>? parts,
    bool? isFavorite,
    bool? isPast,
    String? badge,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      organizer: organizer ?? this.organizer,
      venue: venue ?? this.venue,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      dances: dances ?? this.dances,
      info: info ?? this.info,
      parts: parts ?? this.parts,
      isFavorite: isFavorite ?? this.isFavorite,
      isPast: isPast ?? this.isPast,
      badge: badge ?? this.badge,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        organizer,
        venue,
        startTime,
        endTime,
        duration,
        dances,
        info,
        parts,
        isFavorite,
        isPast,
        badge,
      ];
}
