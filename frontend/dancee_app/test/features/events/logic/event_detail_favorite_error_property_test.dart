// Feature: event-detail-page, Property 7: Favorite toggle error recovery
// **Validates: Requirements 9.4**

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dancee_app/features/events/logic/event_detail.dart';
import 'package:dancee_app/features/events/logic/event_list.dart';

import '../../../helpers/mock_factories.dart';
import '../../../helpers/property_test_helpers.dart';

void main() {
  group('Property 7: Favorite toggle error recovery', () {
    test(
      'toggleFavorite reverts isFavorite to original value when repository '
      'throws, for 100 random events',
      () async {
        for (var i = 0; i < 100; i++) {
          final rng = Random(i);
          final event = randomEvent(rng);

          // Set up mocks
          final mockRepository = MockEventRepository();
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

          // Stub repository to THROW an exception
          when(() => mockRepository.toggleFavorite(any(), any()))
              .thenThrow(Exception('API error'));

          // Create cubit and load event
          final cubit = EventDetailCubit(
            repository: mockRepository,
            eventListCubit: mockEventListCubit,
            eventId: event.id,
          );
          cubit.loadEvent();

          // Record original favorite status
          final originalIsFavorite = event.isFavorite;

          // Act
          await cubit.toggleFavorite();

          // Assert: state is still loaded
          final loadedState = cubit.state;
          expect(
            loadedState,
            isA<EventDetailLoaded>(),
            reason: 'seed=$i: state should be loaded after failed toggleFavorite',
          );

          final loaded = loadedState as EventDetailLoaded;

          // Assert: isFavorite reverted to original value
          expect(
            loaded.event.isFavorite,
            equals(originalIsFavorite),
            reason:
                'seed=$i: isFavorite should revert to $originalIsFavorite '
                'after repository error',
          );

          // Assert: isTogglingFavorite is false
          expect(
            loaded.isTogglingFavorite,
            isFalse,
            reason:
                'seed=$i: isTogglingFavorite should be false after error recovery',
          );

          // Clean up
          await cubit.close();
        }
      },
    );
  });
}
