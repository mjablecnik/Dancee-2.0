// Feature: event-detail-page, Property 1: Favorite icon reflects event state
// **Validates: Requirements 1.4, 9.3**

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dancee_app/features/events/logic/event_detail.dart';
import 'package:dancee_app/features/events/logic/event_list.dart';

import '../../../../helpers/mock_factories.dart';
import '../../../../helpers/property_test_helpers.dart';

void main() {
  group('Property 1: Favorite icon reflects event state', () {
    test(
      'cubit state isFavorite matches the original event isFavorite '
      'for 100 random events',
      () async {
        for (var i = 0; i < 100; i++) {
          final rng = Random(i);
          final event = randomEvent(rng);

          // Set up mocks
          final mockEventListCubit = MockEventListCubit();

          // Stub EventListCubit state with the random event
          when(() => mockEventListCubit.state).thenReturn(
            EventListState.loaded(
              allEvents: [event],
              todayEvents: [],
              tomorrowEvents: [],
              upcomingEvents: [event],
            ),
          );
          when(() => mockEventListCubit.stream)
              .thenAnswer((_) => const Stream.empty());

          // Create cubit (loads event in constructor)
          final cubit = EventDetailCubit(
            eventListCubit: mockEventListCubit,
            eventId: event.id,
          );

          // Assert: state is non-null and isFavorite matches the original event
          expect(
            cubit.state,
            isNotNull,
            reason: 'seed=$i: state should be non-null after construction',
          );
          expect(
            cubit.state!.isFavorite,
            equals(event.isFavorite),
            reason:
                'seed=$i: cubit state isFavorite (${cubit.state!.isFavorite}) '
                'should match original event isFavorite (${event.isFavorite})',
          );

          // Clean up
          await cubit.close();
        }
      },
    );
  });
}
