import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../data/event_repository.dart' as repo;
import '../../../../i18n/strings.g.dart';
import '../components/featured_event_card.dart';

class FeaturedEventsSection extends StatelessWidget {
  final VoidCallback? onEventTap;

  const FeaturedEventsSection({
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
          child: Text(
            t.events.featuredEvents,
            style: TextStyle(
              color: appText,
              fontSize: AppTypography.fontSize3xl,
              fontWeight: AppTypography.fontWeightBold,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        FutureBuilder<List<repo.FeaturedEventData>>(
          future: const repo.EventRepository().getFeaturedEvents(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            final events = snapshot.data!;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Row(
                children: events.asMap().entries.map((entry) {
                  final index = entry.key;
                  final event = entry.value;
                  return Row(
                    children: [
                      if (index > 0) const SizedBox(width: AppSpacing.lg),
                      FeaturedEventCard(
                        imageUrl: event.imageUrl,
                        title: event.title,
                        date: event.date,
                        location: event.location,
                        price: event.price,
                        isFree: event.isFree,
                        isFavorited: event.isFavorited,
                        tags: event.tags
                            .map((tag) => EventTagData(tag.label, tag.color))
                            .toList(),
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
