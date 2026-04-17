import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../i18n/strings.g.dart';
import '../components/course_list_card.dart';

class AllCoursesSection extends StatelessWidget {
  final void Function(String courseId)? onCourseTap;

  const AllCoursesSection({super.key, this.onCourseTap});

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
                t.courses.allCourses,
                style: const TextStyle(
                  color: appText,
                  fontSize: AppTypography.fontSize3xl,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm - 2,
                ),
                decoration: BoxDecoration(
                  color: appSurface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sort, size: 14, color: appText),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: [
              CourseListCard(
                imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/76f620736b-1b30838deee34bc8d92d.png',
                title: 'Kizomba pro začátečníky - Základy a technika',
                instructor: 'Dance Academy Brno',
                dateRange: '10. Led - 20. Bře 2025',
                tags: const [CourseTag('Kizomba', appLavender)],
                price: '1 800 Kč',
                onTap: () => onCourseTap?.call('kizomba-zacatecnici'),
              ),
              const SizedBox(height: AppSpacing.md),
              CourseListCard(
                imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/7aea1ca5f9-df80ba7a33c40f0d747f.png',
                title: 'Zouk Brazilian - Intermediate Level',
                instructor: 'Rodrigo Silva',
                dateRange: '5. Úno - 25. Dub 2025',
                tags: const [CourseTag('Zouk', appTeal)],
                price: '2 900 Kč',
                onTap: () => onCourseTap?.call('zouk-intermediate'),
              ),
              const SizedBox(height: AppSpacing.md),
              CourseListCard(
                imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/a7cd619a31-3615d5bebdd9530c56ad.png',
                title: 'Salsa On2 New York Style - Pokročilí tanečníci',
                instructor: 'Taneční škola Ritmo',
                dateRange: '1. Bře - 30. Kvě 2025',
                tags: const [CourseTag('Salsa', appPrimary)],
                price: '3 500 Kč',
                onTap: () => onCourseTap?.call('salsa-on2'),
              ),
              const SizedBox(height: AppSpacing.md),
              CourseListCard(
                imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/6ade0c4c2f-6feddb3834ecd06ea480.png',
                title: 'Bachata Dominicana - Autentický styl',
                instructor: 'Latino Dance Studio',
                dateRange: '12. Led - 28. Bře 2025',
                tags: const [CourseTag('Bachata', appAccent)],
                price: '2 400 Kč',
                onTap: () => onCourseTap?.call('bachata-dominicana'),
              ),
              const SizedBox(height: AppSpacing.md),
              CourseListCard(
                imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/63212152d8-4a9271e50d1f29074c57.png',
                title: 'West Coast Swing - Základní kurz',
                instructor: 'Swing Time Praha',
                dateRange: '8. Úno - 15. Kvě 2025',
                tags: const [CourseTag('Swing', appGold)],
                price: '2 700 Kč',
                onTap: () => onCourseTap?.call('west-coast-swing'),
              ),
              const SizedBox(height: AppSpacing.md),
              CourseListCard(
                imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/948f834bc0-ab80b9f7f0c22452d82b.png',
                title: 'Salsa & Bachata Combo - Intenzivní víkendový kurz',
                instructor: 'Dance Fusion Ostrava',
                dateRange: '25. Led - 26. Led 2025',
                tags: const [
                  CourseTag('Salsa', appPrimary),
                  CourseTag('Bachata', appAccent),
                ],
                price: '1 200 Kč',
                onTap: () => onCourseTap?.call('salsa-bachata-combo'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
