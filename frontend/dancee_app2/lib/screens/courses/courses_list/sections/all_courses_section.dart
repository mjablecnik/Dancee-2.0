import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../data/course_repository.dart';
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
        FutureBuilder<List<CourseListData>>(
          future: const CourseRepository().getAllCourses(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            final courses = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                children: courses.asMap().entries.map((entry) {
                  final index = entry.key;
                  final course = entry.value;
                  return Column(
                    children: [
                      if (index > 0) const SizedBox(height: AppSpacing.md),
                      CourseListCard(
                        imageUrl: course.imageUrl,
                        title: course.title,
                        instructor: course.instructor,
                        dateRange: course.dateRange,
                        tags: course.tags
                            .map((tag) => CourseTag(tag.label, tag.color))
                            .toList(),
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
