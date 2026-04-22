import 'package:dancee_app2/screens/events/events_list/sections/events_header_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';
import '../../../data/entities/course.dart';
import '../../../i18n/strings.g.dart';
import '../../../logic/cubits/course_cubit.dart';
import '../../../logic/cubits/favorites_cubit.dart';
import '../../../logic/cubits/filter_cubit.dart';
import '../../../logic/cubits/settings_cubit.dart';
import '../../../logic/states/filter_state.dart';
import '../../../logic/states/course_state.dart';
import '../../../shared/sections/dance_styles_filter_section.dart';
import '../../../shared/utils/date_format.dart';
import 'components/course_list_card.dart';

class CoursesListScreen extends StatelessWidget {
  const CoursesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: appBg,
      child: Column(
        children: [
          BlocBuilder<FilterCubit, FilterState>(
            builder: (context, filterState) {
              final regions = filterState.selectedRegions;
              final location = regions.isEmpty
                  ? t.events.filter.allCities
                  : regions.join(', ');
              return EventsHeaderSection(
                location: location,
                onLocationTap: () => context.push('/events/filter-location'),
              );
            },
          ),
          Expanded(
            child: BlocBuilder<CourseCubit, CourseState>(
              builder: (context, state) {
                return state.map(
                  initial: (_) => const SizedBox.shrink(),
                  loading: (_) => const Center(
                    child: CircularProgressIndicator(color: appPrimary),
                  ),
                  loaded: (loaded) => SingleChildScrollView(
                    padding: const EdgeInsets.only(
                        bottom: 16, top: AppSpacing.xxl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BlocBuilder<FilterCubit, FilterState>(
                          builder: (context, filterState) {
                            final filterCubit = context.read<FilterCubit>();
                            final danceStyles = filterCubit.allDanceStyles;
                            final selectedCodes = filterState.selectedDanceStyles;
                            final selectedIndex = danceStyles.indexWhere(
                              (d) => selectedCodes.contains(d.code),
                            );
                            return DanceStylesFilterSection(
                              onShowAll: () => context.push('/events/filter-dance'),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
                        _AllCoursesSection(
                          courses: loaded.filteredCourses,
                          formatDateRange: formatDateRange,
                        ),
                      ],
                    ),
                  ),
                  error: (err) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          err.message,
                          style: const TextStyle(color: appMuted),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        TextButton(
                          onPressed: () {
                            final lang = context.read<SettingsCubit>().currentLanguageCode;
                            context.read<CourseCubit>().loadCourses(lang);
                          },
                          child: Text(t.common.retry,
                              style: const TextStyle(color: appPrimary)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AllCoursesSection extends StatelessWidget {
  final List<Course> courses;
  final String Function(String?, String?) formatDateRange;

  const _AllCoursesSection({
    required this.courses,
    required this.formatDateRange,
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
                      style: const TextStyle(
                          color: appText,
                          fontSize: AppTypography.fontSizeMd),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (courses.isEmpty)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              t.courses.noCoursesFound,
              style: const TextStyle(color: appMuted),
            ),
          )
        else
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              children: courses.asMap().entries.map((entry) {
                final index = entry.key;
                final course = entry.value;
                return Column(
                  children: [
                    if (index > 0) const SizedBox(height: AppSpacing.md),
                    CourseListCard(
                      imageUrl: course.imageUrl ?? '',
                      title: course.title,
                      instructor: course.instructorName ?? '',
                      dateRange:
                          formatDateRange(course.startDate, course.endDate),
                      tags: course.dances
                          .map((d) => CourseTag(d, appPrimary))
                          .toList(),
                      price: course.price ?? '',
                      isFavorited: course.isFavorited,
                      onTap: () =>
                          context.push('/courses/detail?id=${course.id}'),
                      onFavoriteTap: () =>
                          context.read<FavoritesCubit>().toggleFavorite(
                                itemType: 'course',
                                itemId: course.id,
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
