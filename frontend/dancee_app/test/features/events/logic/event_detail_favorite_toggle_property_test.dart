// Feature: event-detail-page, Property 6: Favorite toggle delegation and sync
// **Validates: Requirements 9.1, 9.2**

import 'dart:async';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dancee_app/features/events/logic/event_detail.dart';
import 'package:dancee_app/features/events/logic/event_list.dart';

import '../../../helpers/mock_factories.dart';
import '../../../helpers/property_test_helpers.dart';

void main() {
  group('Property 6: Favorite toggle delegation and sync', () {
    test(
      'toggleFavorite delegates to EventListCubit and cubit syncs via stream '
      'for 100 random events',
      () async {
        for (var i = 0; i < 100; i++) {
          final rng = Random(i);
          final event = randomEvent(rng);
          final flippedEvent = event.copyWith(isFavorite: !event.isFavorite);

          // Set up mocks
          final mockEventListCubit = MockEventListCubit();
          final streamController = StreamController<EventListState>();

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
              .thenAnswer((_) => streamController.stream);

          // Stub toggleFavorite to emit updated state via stream
          when(() => mockEventListCubit.toggleFavorite(any()))
              .thenAnswer((_) async {
            streamController.add(EventListState.loaded(
              allEvents: [flippedEvent],
              todayEvents: [],
              tomorrowEvents: [],
              upcomingEvents: [flippedEvent],
            ));
          });

          // Create cubit (loads event in constructor)
          final cubit = EventDetailCubit(
            eventListCubit: mockEventListCubit,
            eventId: event.id,
          );

          // Verify initial state
          expect(
            cubit.state?.isFavorite,
            equals(event.isFavorite),
            reason: 'seed=$i: initial isFavorite should match event',
          );

          // Act
          await cubit.toggleFavorite();

          // Allow stream event to propagate
          await Future.delayed(Duration.zero);

          // Assert: isFavorite is flipped via stream sync
          expect(
            cubit.state?.isFavorite,
            equals(!event.isFavorite),
            reason:
                'seed=$i: isFavorite should be flipped after stream sync',
          );

          // Assert: delegated to EventListCubit
          verify(
            () => mockEventListCubit.toggleFavorite(event.id),
          ).called(1);

          // Clean up
          await streamController.close();
          await cubit.close();
        }
      },
    );
  });
}
