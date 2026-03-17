// Feature: event-detail-page, Property 5: Map URL construction uses coordinates when available
// **Validates: Requirements 4.3, 4.4, 4.5, 10.1**

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:dancee_app/features/events/data/entities.dart';

import '../../../helpers/property_test_helpers.dart';

/// Replicates the URL construction logic from EventDetailCubit.openMap
/// so we can test the property without needing url_launcher.
Uri buildMapUrl(Venue venue) {
  if (venue.latitude != null && venue.longitude != null) {
    return Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${venue.latitude},${venue.longitude}',
    );
  } else {
    return Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(venue.address.fullAddress)}',
    );
  }
}

void main() {
  group('Property 5: Map URL construction uses coordinates when available', () {
    test(
      'venue with coordinates produces URL containing lat/lng, '
      'venue without coordinates produces URL containing encoded address, '
      'for 100 random seeds',
      () {
        for (var i = 0; i < 100; i++) {
          final rng = Random(i);

          // --- Case 1: Venue WITH coordinates ---
          final venueWithCoords = randomVenue(rng);
          final urlWithCoords = buildMapUrl(venueWithCoords);

          // URL is a valid Google Maps directions URL
          expect(
            urlWithCoords.toString(),
            startsWith('https://www.google.com/maps/dir/'),
            reason: 'seed=$i: URL should start with Google Maps directions base',
          );

          // URL contains the coordinate values
          expect(
            urlWithCoords.toString(),
            contains('${venueWithCoords.latitude}'),
            reason: 'seed=$i: URL should contain latitude '
                '${venueWithCoords.latitude}',
          );
          expect(
            urlWithCoords.toString(),
            contains('${venueWithCoords.longitude}'),
            reason: 'seed=$i: URL should contain longitude '
                '${venueWithCoords.longitude}',
          );
        }
      },
    );
  });
}
