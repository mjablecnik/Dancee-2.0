// Feature: event-detail-page, Property 3: Date formatting produces day-of-week and date
// **Validates: Requirements 2.3**

import 'dart:math';

import 'package:dancee_app/features/events/pages/event_detail/components.dart';
import 'package:dancee_app/i18n/translations.g.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/property_test_helpers.dart';

void main() {
  setUp(() {
    LocaleSettings.setLocale(AppLocale.en);
  });

  group('Property 3: Date formatting produces day-of-week and date', () {
    test(
      'for any valid DateTime, formatDate produces a non-empty string '
      'with a recognizable date — 100 random seeds',
      () {
        final months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
        ];

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(const Duration(days: 1));

        for (var seed = 0; seed < 100; seed++) {
          final rng = Random(seed);
          final dateTime = randomDateTime(rng);
          final result = formatDate(dateTime);

          // Result is always non-empty
          expect(
            result.isNotEmpty,
            isTrue,
            reason: 'seed=$seed: formatDate should never return empty string',
          );

          final eventDate = DateTime(
            dateTime.year,
            dateTime.month,
            dateTime.day,
          );

          if (eventDate == today) {
            // Today's date returns the "today" translation
            expect(
              result,
              equals(t.today),
              reason: 'seed=$seed: today date should return "${t.today}", '
                  'got "$result"',
            );
          } else if (eventDate == tomorrow) {
            // Tomorrow's date returns the "tomorrow" translation
            expect(
              result,
              equals(t.tomorrow),
              reason: 'seed=$seed: tomorrow date should return "${t.tomorrow}", '
                  'got "$result"',
            );
          } else {
            // Non-today/tomorrow: format is "{day}. {MonthAbbr} {year}"
            final expectedMonth = months[dateTime.month - 1];
            final expected =
                '${dateTime.day}. $expectedMonth ${dateTime.year}';
            expect(
              result,
              equals(expected),
              reason: 'seed=$seed: expected "$expected", got "$result"',
            );

            // Also verify it contains the day number, month abbreviation, and year
            expect(
              result.contains('${dateTime.day}'),
              isTrue,
              reason: 'seed=$seed: result should contain day number',
            );
            expect(
              months.any((m) => result.contains(m)),
              isTrue,
              reason: 'seed=$seed: result should contain a month abbreviation',
            );
            expect(
              result.contains('${dateTime.year}'),
              isTrue,
              reason: 'seed=$seed: result should contain the year',
            );
          }
        }
      },
    );
  });
}
