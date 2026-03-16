import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/service_locator.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/entities.dart';
import '../../logic/event_detail.dart';
import '../../../app/layouts.dart';
import '../event_list/event_list_page.dart';
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
/// Uses [EventDetailCubit] via [BlocProvider] to manage state.
/// The cubit emits [Event?] directly — null means event not found.
class EventDetailPage extends StatelessWidget {
  final String eventId;

  const EventDetailPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<EventDetailCubit>(param1: eventId),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocConsumer<EventDetailCubit, Event?>(
          listenWhen: (previous, current) =>
              previous != null &&
              current != null &&
              previous.isFavorite != current.isFavorite,
          listener: (context, event) {
            if (event == null) return;
            final message = event.isFavorite
                ? t.eventDetail.addedToFavorites
                : t.eventDetail.removedFromFavorites;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          builder: (context, event) {
            if (event == null) {
              return EventNotFoundSection(
                onBackPressed: () => const EventListRoute().go(context),
              );
            }
            return _EventDetailContent(event: event);
          },
        ),
      ),
    );
  }
}

/// Wraps the scrollable content of the event detail page.
///
/// Separated into its own widget so callbacks can access the
/// [EventDetailCubit] from the [BlocProvider] above.
class _EventDetailContent extends StatelessWidget {
  final Event event;

  const _EventDetailContent({required this.event});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EventDetailCubit>();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EventDetailHeaderSection(
            event: event,
            onBackPressed: () => context.pop(),
            onFavoritePressed: () => cubit.toggleFavorite(),
            onMapPressed: () => cubit.openMap(event.venue),
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
                EventVenueSection(
                  venue: event.venue,
                  onNavigatePressed: () => cubit.openMap(event.venue),
                ),
                const SizedBox(height: 20),
                EventOrganizerSection(organizer: event.organizer),
                const SizedBox(height: 20),
                EventDescriptionSection(description: event.description),
                if (event.info.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  EventInfoSection(
                    info: event.info,
                    onUrlTapped: (url) => cubit.openUrl(url),
                  ),
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
  }
}
