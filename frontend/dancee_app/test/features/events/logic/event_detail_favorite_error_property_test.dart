// Feature: event-detail-page, Property 7: Favorite toggle error — detail cubit unchanged
// **Validates: Requirements 9.4**

import 'dart:async';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dancee_app/features/events/logic/event_detail.dart';
import 'package:dancee_app/features/events/logic/event_list.dart';

import '../../../helpers/mock_factories.dart';
import '../../../helpers/property_test_helpers.dart';

void main() {
  group('Property 7: Favorite toggle error — detail cubit unchanged', () {
    test(
      'when EventListCubit emits error, detail cubit Event? stays unchanged '
      'for 100 random events',
      () async {
        for (var i = 0; i < 100; i++) {
          final rng = Random(i);
          final event = randomEvent(rng);

          // Set up mocks
          final mockEventListCubit = MockEventListCubit();
          final streamController = StreamController<EventListState>();

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
              .thenAnswer((_) => streamController.stream);

          // Stub toggleFavorite to emit error state via stream
          when(() => mockEventListCubit.toggleFavorite(any()))
              .thenAnswer((_) async {
            streamController.add(
              const EventListState.error('Failed to toggle favorite'),
            );
          });

          // Create cubit (loads event in constructor)
          final cubit = EventDetailCubit(
            eventListCubit: mockEventListCubit,
            eventId: event.id,
          );

          // Record original state
          final originalIsFavorite = cubit.state?.isFavorite;

          // Act
          await cubit.toggleFavorite();

          // Allow stream event to propagate
          await Future.delayed(Duration.zero);

          // Assert: Event? state is unchanged (error state is ignored by cubit)
          expect(
            cubit.state,
            isNotNull,
            reason: 'seed=$i: state should still be non-null after error',
          );
          expect(
            cubit.state!.isFavorite,
            equals(originalIsFavorite),
            reason:
                'seed=$i: isFavorite should remain $originalIsFavorite '
                'after EventListCubit error',
          );

          // Clean up
          await streamController.close();
          await cubit.close();
        }
      },
    );
  });
}
