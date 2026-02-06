import 'package:equatable/equatable.dart';

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

  /// The end time of this event part
  final DateTime endTime;

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
    required this.endTime,
    this.lectors,
    this.djs,
  });

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
  List<Object?> get props => [name, description, type, startTime, endTime, lectors, djs];
}
