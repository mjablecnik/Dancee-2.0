import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../data/course_repository.dart';
import '../../../../i18n/strings.g.dart';
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
              Text(
                t.courses.featuredCourses,
                style: const TextStyle(
                  color: appText,
                  fontSize: AppTypography.fontSize3xl,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: onShowAll,
                child: Text(
                  t.common.showAll,
                  style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeMd),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        FutureBuilder<List<FeaturedCourseData>>(
          future: const CourseRepository().getFeaturedCourses(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            final courses = snapshot.data!;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Row(
                children: courses.asMap().entries.map((entry) {
                  final index = entry.key;
                  final course = entry.value;
                  return Row(
                    children: [
                      if (index > 0) const SizedBox(width: AppSpacing.lg),
                      FeaturedCourseCard(
                        imageUrl: course.imageUrl,
                        levelLabel: course.levelLabel,
                        levelColor: course.levelColor,
                        title: course.title,
                        instructor: course.instructor,
                        dateRange: course.dateRange,
                        styleLabel: course.styleLabel,
                        styleColor: course.styleColor,
                        price: course.price,
                        onTap: () => onCourseTap?.call(course.id),
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
