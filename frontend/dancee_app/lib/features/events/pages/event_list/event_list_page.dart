import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/service_locator.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/entities.dart';
import '../../logic/event_list.dart';
import 'sections.dart';

/// Route definition for the event list page.
///
/// Uses [NoTransitionPage] to disable page transition animations,
/// following the app's routing convention.
///
/// Note: The @TypedGoRoute annotation is defined in the shell route
/// (AppLayoutRoute in layouts.dart), not here.
class EventListRoute extends GoRouteData {
  const EventListRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(child: EventListPage());
  }
}

/// Main page displaying a list of dance events grouped by date.
///
/// Uses [BlocBuilder] to reactively render UI based on [EventListCubit] state:
/// - initial: empty placeholder
/// - loading: centered loading indicator
/// - loaded: scrollable list with header, search/filters, and events by date
/// - error: error message with retry action
class EventListPage extends StatelessWidget {
  const EventListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: BlocBuilder<EventListCubit, EventListState>(
          bloc: getIt<EventListCubit>(),
          builder: (context, state) {
            return state.when(
              initial: () => const SizedBox.shrink(),
              loading: () => const LoadingSection(),
              loaded: (allEvents, todayEvents, tomorrowEvents, upcomingEvents) {
                return CustomScrollView(
                  slivers: [
                    const EventListHeaderSection(),
                    const SliverToBoxAdapter(
                      child: SearchAndFiltersSection(),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
                      sliver: EventsByDateSection(
                        todayEvents: todayEvents,
                        tomorrowEvents: tomorrowEvents,
                        upcomingEvents: upcomingEvents,
                      ),
                    ),
                  ],
                );
              },
              error: (message) => ErrorSection(message: message),
            );
          },
        ),
      ),
    );
  }
}
