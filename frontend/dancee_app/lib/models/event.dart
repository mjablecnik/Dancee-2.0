import 'package:equatable/equatable.dart';
import 'venue.dart';
import 'event_info.dart';
import 'event_part.dart';

/// Represents a dance event with all its details.
///
/// This is the main model class for dance events in the application.
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

  /// The end time of the event
  final DateTime endTime;

  /// The duration of the event
  final Duration duration;

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
    required this.endTime,
    required this.duration,
    required this.dances,
    this.info = const [],
    this.parts = const [],
    this.isFavorite = false,
    this.isPast = false,
    this.badge,
  });

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
