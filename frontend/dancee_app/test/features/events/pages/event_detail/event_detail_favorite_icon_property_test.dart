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
      'loaded state isFavorite matches the original event isFavorite '
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

          // Create cubit and load event
          final cubit = EventDetailCubit(
            repository: MockEventRepository(),
            eventListCubit: mockEventListCubit,
            eventId: event.id,
          );
          cubit.loadEvent();

          // Assert: state is loaded and isFavorite matches the original event
          final loadedState = cubit.state;
          expect(
            loadedState,
            isA<EventDetailLoaded>(),
            reason: 'seed=$i: state should be loaded after loadEvent',
          );

          final stateEvent = (loadedState as EventDetailLoaded).event;
          expect(
            stateEvent.isFavorite,
            equals(event.isFavorite),
            reason:
                'seed=$i: loaded state isFavorite (${stateEvent.isFavorite}) '
                'should match original event isFavorite (${event.isFavorite})',
          );

          // Clean up
          await cubit.close();
        }
      },
    );
  });
}
