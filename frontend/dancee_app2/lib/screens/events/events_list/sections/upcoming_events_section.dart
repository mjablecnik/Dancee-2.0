import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../data/entities/dance_style.dart';
import '../../../../data/entities/event.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../logic/cubits/favorites_cubit.dart';
import '../../../../shared/utils/date_format.dart';
import '../components/featured_event_card.dart' show EventTagData;
import '../components/upcoming_event_card.dart';

/// Max number of dance style tags shown per event card.
const _kMaxDanceTags = 6;

/// Resolves dance codes/names to unique parent display names, limited to [_kMaxDanceTags].
///
/// Each dance in [codes] is matched against [allStyles] by code or name.
/// If a match has a parentCode, the parent's name is used instead.
/// Unmatched codes are kept as-is.
List<String> parentDanceNames(List<String> codes, List<DanceStyle> allStyles) {
  final names = <String>[];
  for (final code in codes) {
    // Match by code first, then by name (case-insensitive)
    final style = allStyles.where((s) => s.code == code).firstOrNull ??
        allStyles.where((s) => s.name.toLowerCase() == code.toLowerCase()).firstOrNull;

    String displayName;
    if (style != null && style.parentCode != null) {
      // Resolve to parent name
      final parent = allStyles.where((s) => s.code == style.parentCode).firstOrNull;
      displayName = parent?.name ?? code;
    } else if (style != null) {
      // Already a parent style
      displayName = style.name;
    } else {
      displayName = code;
    }

    if (!names.contains(displayName)) names.add(displayName);
    if (names.length >= _kMaxDanceTags) break;
  }
  return names;
}

class UpcomingEventsSection extends StatelessWidget {
  final List<Event> events;
  final List<DanceStyle> allDanceStyles;
  final bool hasActiveFilters;
  final VoidCallback? onClearFilters;
  final void Function(int eventId)? onEventTap;

  const UpcomingEventsSection({
    super.key,
    required this.events,
    this.allDanceStyles = const [],
    this.hasActiveFilters = false,
    this.onClearFilters,
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
        if (events.isEmpty && hasActiveFilters)
          SizedBox(
            height: 200,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      t.events.noEventsForFilter,
                      style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextButton(
                      onPressed: onClearFilters,
                      child: Text(
                        t.common.clearFilters,
                        style: const TextStyle(color: appPrimary, fontSize: AppTypography.fontSizeMd),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: events.asMap().entries.map((entry) {
              final index = entry.key;
              final event = entry.value;
              return Column(
                children: [
                  if (index > 0) const SizedBox(height: AppSpacing.lg),
                  UpcomingEventCard(
                    imageUrl: event.imageUrl ?? '',
                    title: event.title,
                    location: event.venue?.town ?? event.venue?.name ?? '',
                    date: formatDate(event.startTime),
                    tags: parentDanceNames(event.dances, allDanceStyles)
                        .map((name) => EventTagData(name, appPrimary))
                        .toList(),
                    isFavorited: event.isFavorited,
                    onTap: () => onEventTap?.call(event.id),
                    onFavoriteTap: () => context.read<FavoritesCubit>().toggleFavorite(
                          itemType: 'event',
                          itemId: event.id,
                        ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
