import 'package:equatable/equatable.dart';

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
