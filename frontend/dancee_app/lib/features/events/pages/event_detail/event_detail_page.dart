import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/service_locator.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/entities.dart';
import '../../logic/event_list.dart';
import 'sections.dart';

part 'event_detail_page.g.dart';

/// Route definition for the event detail page.
///
/// Receives an event [id] via route parameters and uses [NoTransitionPage]
/// to disable page transition animations.
@TypedGoRoute<EventDetailRoute>(path: '/events/:id')
class EventDetailRoute extends GoRouteData {
  final String id;

  const EventDetailRoute({required this.id});

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(child: EventDetailPage(eventId: id));
  }
}

/// Page displaying full details of a dance event.
///
/// Uses the [EventListCubit] to find the event by ID from the already-loaded
/// list. This is a placeholder implementation with no additional backend calls.
class EventDetailPage extends StatelessWidget {
  final String eventId;

  const EventDetailPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<EventListCubit, EventListState>(
        bloc: getIt<EventListCubit>(),
        builder: (context, state) {
          final event = _findEvent(state);

          if (event == null) {
            return EventNotFoundSection(
              onBackPressed: () => context.go('/events'),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EventDetailHeaderSection(
                  event: event,
                  onBackPressed: () => context.pop(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      EventTitleSection(event: event),
                      const SizedBox(height: 20),
                      DanceStylesSection(dances: event.dances),
                      const SizedBox(height: 20),
                      EventVenueSection(venue: event.venue),
                      const SizedBox(height: 20),
                      EventOrganizerSection(organizer: event.organizer),
                      const SizedBox(height: 20),
                      EventDescriptionSection(description: event.description),
                      if (event.info.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        EventInfoSection(info: event.info),
                      ],
                      if (event.parts.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        EventPartsSection(parts: event.parts),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Event? _findEvent(EventListState state) {
    return state.whenOrNull(
      loaded: (allEvents, todayEvents, tomorrowEvents, upcomingEvents) {
        try {
          return allEvents.firstWhere((e) => e.id == eventId);
        } catch (_) {
          return null;
        }
      },
    );
  }
}
