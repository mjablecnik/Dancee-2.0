import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';
import '../../../data/event_repository.dart';
import '../../../i18n/strings.g.dart';
import '../../events/events_list/components/upcoming_event_card.dart';

class SavedEventsListSection extends StatelessWidget {
  const SavedEventsListSection({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UpcomingEventData>>(
      future: const EventRepository().getSavedEvents(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final events = snapshot.data!;

        if (events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FaIcon(
                  FontAwesomeIcons.heart,
                  size: 48,
                  color: appMuted,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  t.saved.emptyTitle,
                  style: const TextStyle(
                    color: appText,
                    fontSize: AppTypography.fontSizeLg,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  t.saved.emptySubtitle,
                  style: const TextStyle(
                    color: appMuted,
                    fontSize: AppTypography.fontSizeMd,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: [
              for (int i = 0; i < events.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.lg),
                UpcomingEventCard(
                  imageUrl: events[i].imageUrl,
                  title: events[i].title,
                  location: events[i].location,
                  date: events[i].date,
                  tags: events[i].tags,
                  isFavorited: events[i].isFavorited,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
