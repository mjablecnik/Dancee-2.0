// Feature: event-detail-page, Property 6: Favorite toggle round trip
// **Validates: Requirements 9.1, 9.2**

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dancee_app/features/events/data/event_repository.dart';
import 'package:dancee_app/features/events/logic/event_detail.dart';
import 'package:dancee_app/features/events/logic/event_list.dart';

import '../../../helpers/mock_factories.dart';
import '../../../helpers/property_test_helpers.dart';

void main() {
  group('Property 6: Favorite toggle round trip', () {
    test(
      'toggleFavorite flips isFavorite and calls repository correctly '
      'for 100 random events',
      () async {
        for (var i = 0; i < 100; i++) {
          final rng = Random(i);
          final event = randomEvent(rng);

          // Set up mocks
          final mockRepository = MockEventRepository();
          final mockEventListCubit = MockEventListCubit();

          // Stub EventListCubit state with the random event in allEvents
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
          when(() => mockRepository.toggleFavorite(any(), any()))
              .thenAnswer((_) => Future.value());
          when(() => mockEventListCubit.loadEvents())
              .thenAnswer((_) => Future.value());

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

          // Assert: isFavorite is flipped
          final loadedState = cubit.state;
          expect(
            loadedState,
            isA<EventDetailLoaded>(),
            reason: 'seed=$i: state should be loaded after toggleFavorite',
          );
          expect(
            (loadedState as EventDetailLoaded).event.isFavorite,
            equals(!originalIsFavorite),
            reason:
                'seed=$i: isFavorite should be flipped from $originalIsFavorite '
                'to ${!originalIsFavorite}',
          );

          // Assert: repository called with correct args
          verify(
            () => mockRepository.toggleFavorite(event.id, originalIsFavorite),
          ).called(1);

          // Clean up
          await cubit.close();
        }
      },
    );
  });
}
