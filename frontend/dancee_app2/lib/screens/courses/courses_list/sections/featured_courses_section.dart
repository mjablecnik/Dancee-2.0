import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../components/featured_course_card.dart';

class FeaturedCoursesSection extends StatelessWidget {
  final VoidCallback? onShowAll;
  final void Function(String courseId)? onCourseTap;

  const FeaturedCoursesSection({
    super.key,
    this.onShowAll,
    this.onCourseTap,
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
                'Doporučené kurzy',
                style: TextStyle(
                  color: appText,
                  fontSize: AppTypography.fontSize3xl,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: onShowAll,
                child: const Text(
                  'Zobrazit vše',
                  style: TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Row(
            children: [
              FeaturedCourseCard(
                imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/b7b07c55da-1a5df97edf8c1ed85c9a.png',
                levelLabel: 'Začátečníci',
                levelColor: appPrimary,
                title: 'Salsa Cubana pro začátečníky',
                instructor: 'Dance Studio Praha',
                dateRange: '15. Led - 30. Dub 2025',
                styleLabel: 'Salsa',
                styleColor: appPrimary,
                price: '2 500 Kč',
                onTap: () => onCourseTap?.call('salsa-cubana'),
              ),
              const SizedBox(width: AppSpacing.lg),
              FeaturedCourseCard(
                imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/5a2ccba7af-f45a64d9fa0f2acd8902.png',
                levelLabel: 'Pokročilí',
                levelColor: appAccent,
                title: 'Bachata Sensual Advanced',
                instructor: 'Carlos & Maria',
                dateRange: '1. Úno - 15. Kvě 2025',
                styleLabel: 'Bachata',
                styleColor: appAccent,
                price: '3 200 Kč',
                onTap: () => onCourseTap?.call('bachata-sensual'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
