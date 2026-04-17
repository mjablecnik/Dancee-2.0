import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
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
              const Text(
                'Nadcházející akce',
                style: TextStyle(
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
                child: const Row(
                  children: [
                    FaIcon(FontAwesomeIcons.arrowUpWideShort, size: 14, color: appText),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Datum',
                      style: TextStyle(color: appText, fontSize: AppTypography.fontSizeMd),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: [
              UpcomingEventCard(
                imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/a7414ef4de-19550fae1cabebe15c09.png',
                title: 'Bachata Sensual Workshop s mezinárodními lektory',
                location: 'Dance Studio 1, Brno',
                date: '20. Říj, 14:00',
                style: 'Bachata',
                styleColor: appAccent,
                isFavorited: false,
                onTap: onEventTap,
              ),
              const SizedBox(height: AppSpacing.lg),
              UpcomingEventCard(
                imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/9d038750ea-18e3a1b3f78567f6cc57.png',
                title: 'Havana Night - Živá kapela a animace',
                location: 'Klub Tres, Ostrava',
                date: '22. Říj, 20:00',
                style: 'Salsa',
                styleColor: appPrimary,
                isFavorited: true,
                onTap: onEventTap,
              ),
              const SizedBox(height: AppSpacing.lg),
              UpcomingEventCard(
                imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/858406cadf-a18221d3c2f7fc2a6f2a.png',
                title: 'Zouk Weekend Marathon 2025',
                location: 'Hotel Pyramida, Praha',
                date: '1. Lis - 3. Lis',
                style: 'Zouk',
                styleColor: appTeal,
                isFavorited: false,
                onTap: onEventTap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
