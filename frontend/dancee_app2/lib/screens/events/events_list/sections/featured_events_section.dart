import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Text(
            'Doporučené akce',
            style: TextStyle(
              color: appText,
              fontSize: AppTypography.fontSize3xl,
              fontWeight: AppTypography.fontWeightBold,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Row(
            children: [
              FeaturedEventCard(
                imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/1887dced68-753b152bd32ad7f3eb9b.png',
                title: 'Prague Latin Festival 2025 - Mega Edition',
                date: '12. Říj - 14. Říj 2025',
                location: 'Kongresové centrum, Praha',
                price: 'Od 350 Kč',
                isFree: false,
                isFavorited: false,
                tags: const [
                  EventTagData('Salsa', appPrimary),
                  EventTagData('Bachata', appAccent),
                ],
                onTap: onEventTap,
              ),
              const SizedBox(width: AppSpacing.lg),
              FeaturedEventCard(
                imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/35e8621ce9-d463887a55ba17b5c416.png',
                title: 'Kizomba Open Air Social',
                date: 'Dnes, 18:00 - 23:00',
                location: 'Střelecký ostrov, Praha',
                price: 'Zdarma',
                isFree: true,
                isFavorited: true,
                tags: const [
                  EventTagData('Kizomba', appLavender),
                  EventTagData('Semba', appLightBlue),
                ],
                onTap: onEventTap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
