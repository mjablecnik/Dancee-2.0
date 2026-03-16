// Feature: event-detail-page, Property 4: Time range formatting
// **Validates: Requirements 2.4, 2.5**

import 'dart:math';

import 'package:dancee_app/features/events/pages/event_detail/components.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/property_test_helpers.dart';

void main() {
  group('Property 4: Time range formatting', () {
    test(
      'for any start/end DateTime pair, output matches "HH:MM - HH:MM"; '
      'for null end, output is "HH:MM" — 100 random seeds',
      () {
        final hhmmPattern = RegExp(r'^\d{2}:\d{2}$');
        final rangePattern = RegExp(r'^\d{2}:\d{2} - \d{2}:\d{2}$');

        for (var seed = 0; seed < 100; seed++) {
          final rng = Random(seed);
          final start = randomDateTime(rng);
          final hasEnd = rng.nextBool();
          final end = hasEnd
              ? start.add(Duration(minutes: 1 + rng.nextInt(600)))
              : null;

          final result = formatTimeRange(start, end);

          if (end == null) {
            // Null end → "HH:MM"
            expect(
              hhmmPattern.hasMatch(result),
              isTrue,
              reason: 'seed=$seed: null end should produce "HH:MM", '
                  'got "$result"',
            );

            // Verify actual values are zero-padded
            final expectedStart =
                '${start.hour.toString().padLeft(2, '0')}:'
                '${start.minute.toString().padLeft(2, '0')}';
            expect(
              result,
              equals(expectedStart),
              reason: 'seed=$seed: expected "$expectedStart", got "$result"',
            );
          } else {
            // Non-null end → "HH:MM - HH:MM"
            expect(
              rangePattern.hasMatch(result),
              isTrue,
              reason: 'seed=$seed: non-null end should produce '
                  '"HH:MM - HH:MM", got "$result"',
            );

            final expectedStart =
                '${start.hour.toString().padLeft(2, '0')}:'
                '${start.minute.toString().padLeft(2, '0')}';
            final expectedEnd =
                '${end.hour.toString().padLeft(2, '0')}:'
                '${end.minute.toString().padLeft(2, '0')}';
            expect(
              result,
              equals('$expectedStart - $expectedEnd'),
              reason: 'seed=$seed: expected '
                  '"$expectedStart - $expectedEnd", got "$result"',
            );
          }
        }
      },
    );
  });
}
