// Feature: event-detail-page, Property 8: Event part type label mapping
// **Validates: Requirements 8.3**

import 'dart:math';

import 'package:dancee_app/features/events/data/entities.dart';
import 'package:dancee_app/features/events/pages/event_detail/components.dart';
import 'package:dancee_app/i18n/translations.g.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/property_test_helpers.dart';

void main() {
  setUp(() {
    LocaleSettings.setLocale(AppLocale.en);
  });

  group('Property 8: Event part type label mapping', () {
    test(
      'for any EventPartType value, the label function returns the correct '
      'localized string and is non-empty — 100 random seeds',
      () {
        for (var seed = 0; seed < 100; seed++) {
          final rng = Random(seed);
          final type = randomEventPartType(rng);
          final label = getPartTypeLabel(type);

          // Label must be non-empty
          expect(
            label.isNotEmpty,
            isTrue,
            reason: 'seed=$seed: label for $type should be non-empty',
          );

          // Label must match the correct English translation
          switch (type) {
            case EventPartType.workshop:
              expect(
                label,
                equals(t.eventDetail.workshop),
                reason: 'seed=$seed: workshop label mismatch',
              );
            case EventPartType.party:
              expect(
                label,
                equals(t.eventDetail.party),
                reason: 'seed=$seed: party label mismatch',
              );
            case EventPartType.openLesson:
              expect(
                label,
                equals(t.eventDetail.openLesson),
                reason: 'seed=$seed: openLesson label mismatch',
              );
          }
        }
      },
    );
  });
}
