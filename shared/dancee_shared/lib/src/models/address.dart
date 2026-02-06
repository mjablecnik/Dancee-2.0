import 'package:equatable/equatable.dart';

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

  /// Returns the full address as a formatted string.
  ///
  /// Format: "street, postalCode city, country"
  /// Example: "Vodičkova 36, 110 00 Prague, Czech Republic"
  String get fullAddress => '$street, $postalCode $city, $country';

  @override
  List<Object?> get props => [street, city, postalCode, country];
}
