import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../data/event_repository.dart';
import '../../../../i18n/strings.g.dart';
import '../components/upcoming_event_card.dart';

class UpcomingEventsSection extends StatelessWidget {
  final VoidCallback? onEventTap;

  const UpcomingEventsSection({
    super.key,
    this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                t.events.upcomingEvents,
                style: const TextStyle(
                  color: appText,
                  fontSize: AppTypography.fontSize3xl,
                  fontWeight: AppTypography.fontWeightBold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
                decoration: BoxDecoration(
                  color: appSurface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    const FaIcon(FontAwesomeIcons.arrowUpWideShort, size: 14, color: appText),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      t.common.date,
                      style: const TextStyle(color: appText, fontSize: AppTypography.fontSizeMd),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        FutureBuilder<List<UpcomingEventData>>(
          future: const EventRepository().getUpcomingEvents(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            final events = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                children: events.asMap().entries.map((entry) {
                  final index = entry.key;
                  final event = entry.value;
                  return Column(
                    children: [
                      if (index > 0) const SizedBox(height: AppSpacing.lg),
                      UpcomingEventCard(
                        imageUrl: event.imageUrl,
                        title: event.title,
                        location: event.location,
                        date: event.date,
                        tags: event.tags,
                        isFavorited: event.isFavorited,
                        onTap: onEventTap,
                      ),
                    ],
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}
