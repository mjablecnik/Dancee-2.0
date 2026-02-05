import 'package:equatable/equatable.dart';
import 'address.dart';

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

  /// Creates a Venue with all required fields.
  const Venue({
    required this.name,
    required this.address,
    required this.description,
    required this.latitude,
    required this.longitude,
  });

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
