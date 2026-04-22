import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';
import '../../../data/entities/course.dart';
import '../../../i18n/strings.g.dart';
import '../../../logic/cubits/course_cubit.dart';
import '../../../logic/cubits/favorites_cubit.dart';
import '../../../logic/states/course_state.dart';
import '../../../shared/sections/description_section.dart';
import '../../../shared/sections/detail_header_section.dart';
import '../../../shared/sections/hero_image_section.dart';
import '../../../shared/sections/key_info_section.dart';
import 'sections/course_instructor_section.dart';
import 'sections/course_pricing_section.dart';
import 'sections/course_schedule_section.dart';
import 'sections/course_title_section.dart';

class CourseDetailScreen extends StatelessWidget {
  final int courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  List<KeyInfoItem> _buildKeyInfo(Course course) {
    final items = <KeyInfoItem>[];

    // Date range
    if (course.startDate != null) {
      final startStr = _formatDate(course.startDate);
      final endStr =
          course.endDate != null ? ' – ${_formatDate(course.endDate)}' : '';
      items.add(KeyInfoItem(
        icon: FontAwesomeIcons.calendar,
        title: '$startStr$endStr',
        subtitle: [
          if (course.scheduleDay != null) course.scheduleDay!,
          if (course.scheduleTime != null) course.scheduleTime!,
        ].join(' '),
      ));
    }

    // Venue
    if (course.venue != null) {
      items.add(KeyInfoItem(
        icon: FontAwesomeIcons.locationDot,
        title: course.venue!.name,
        subtitle: course.venue!.fullAddress,
      ));
    }

    // Lesson count + duration
    if (course.lessonCount != null) {
      final durationStr = course.lessonDurationMinutes != null
          ? ' × ${t.courses.detail.durationMin(count: course.lessonDurationMinutes!)}'
          : '';
      items.add(KeyInfoItem(
        icon: FontAwesomeIcons.chalkboard,
        title: '${t.courses.detail.lessonsCount(count: course.lessonCount!)}$durationStr',
        subtitle: '',
      ));
    }

    // Participants
    if (course.maxParticipants != null) {
      final current = course.currentParticipants ?? 0;
      final max = course.maxParticipants!;
      items.add(KeyInfoItem(
        icon: FontAwesomeIcons.users,
        title: t.courses.detail.participantsCount(current: current, max: max),
        subtitle: t.courses.detail.spotsAvailable(count: max - current),
      ));
    }

    // Instructor
    if (course.instructorName != null && course.instructorName!.isNotEmpty) {
      items.add(KeyInfoItem(
        icon: FontAwesomeIcons.userTie,
        title: course.instructorName!,
        subtitle: '',
      ));
    }

    return items;
  }

  List<ScheduleDetail> _buildScheduleDetails(Course course) {
    final details = <ScheduleDetail>[];

    if (course.startDate != null) {
      details.add(ScheduleDetail(
        label: t.courses.detail.startDate,
        value: _formatDate(course.startDate),
      ));
    }
    if (course.endDate != null) {
      details.add(ScheduleDetail(
        label: t.courses.detail.endDate,
        value: _formatDate(course.endDate),
      ));
    }
    if (course.scheduleDay != null) {
      details.add(ScheduleDetail(
        label: t.courses.detail.day,
        value: course.scheduleDay!,
      ));
    }
    if (course.scheduleTime != null) {
      details.add(ScheduleDetail(
        label: t.courses.detail.time,
        value: course.scheduleTime!,
      ));
    }
    if (course.lessonCount != null) {
      details.add(ScheduleDetail(
        label: t.courses.detail.lessons,
        value: course.lessonCount.toString(),
      ));
    }
    if (course.lessonDurationMinutes != null) {
      details.add(ScheduleDetail(
        label: t.courses.detail.duration,
        value: t.courses.detail.durationMin(count: course.lessonDurationMinutes!),
      ));
    }
    if (course.level != null) {
      details.add(ScheduleDetail(
        label: t.courses.detail.level,
        value: course.level!,
      ));
    }

    return details;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      body: Column(
        children: [
          DetailHeaderSection(
            title: t.courses.detail.header,
            onBack: () => context.pop(),
          ),
          Expanded(
            child: BlocBuilder<CourseCubit, CourseState>(
              builder: (context, state) {
                final course = state.maybeMap(
                  loaded: (s) =>
                      s.allCourses.where((c) => c.id == courseId).firstOrNull,
                  orElse: () => null,
                );

                if (course == null) {
                  return state.maybeMap(
                    loading: (_) => const Center(
                      child: CircularProgressIndicator(color: appPrimary),
                    ),
                    orElse: () => const Center(
                      child: Text(
                        'Course not found',
                        style: TextStyle(color: appMuted),
                      ),
                    ),
                  );
                }

                return BlocBuilder<FavoritesCubit, dynamic>(
                  builder: (context, _) {
                    final isFavorited = context
                        .read<FavoritesCubit>()
                        .isFavorited('course', course.id);

                    final spotsAvailable = course.maxParticipants != null
                        ? '${(course.maxParticipants! - (course.currentParticipants ?? 0))}'
                        : '';
                    final spotsTotal = course.maxParticipants != null
                        ? '${course.maxParticipants}'
                        : '';

                    return SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 100),
                      child: Column(
                        children: [
                          HeroImageSection(
                            imageUrl: course.imageUrl ?? '',
                            topLeft: course.level != null
                                ? HeroLabelBadge(label: course.level!)
                                : null,
                            topRight: HeroFavoriteButton(
                              isFavorite: isFavorited,
                              onTap: () => context
                                  .read<FavoritesCubit>()
                                  .toggleFavorite(
                                    itemType: 'course',
                                    itemId: course.id,
                                  ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: AppSpacing.xxl),
                                CourseTitleSection(
                                  title: course.title,
                                  styleChips: course.dances
                                      .map((d) => StyleChipData(
                                            label: d,
                                            color: appPrimary,
                                          ))
                                      .toList(),
                                ),
                                const SizedBox(height: AppSpacing.xxl),
                                KeyInfoSection(
                                  items: _buildKeyInfo(course),
                                ),
                                if (course.description.isNotEmpty) ...[
                                  const SizedBox(height: AppSpacing.xxl),
                                  DescriptionSection(
                                    title: t.courses.detail.description,
                                    paragraphs: course.description
                                        .split('\n\n')
                                        .where((p) => p.trim().isNotEmpty)
                                        .toList(),
                                  ),
                                ],
                                const SizedBox(height: AppSpacing.xxl),
                                CourseScheduleSection(
                                  details: _buildScheduleDetails(course),
                                  learningItems: course.learningItems,
                                ),
                                if (course.instructorName != null &&
                                    course.instructorName!.isNotEmpty) ...[
                                  const SizedBox(height: AppSpacing.xxl),
                                  CourseInstructorSection(
                                    avatarUrl:
                                        course.instructorAvatarUrl ?? '',
                                    name: course.instructorName!,
                                    bio: course.instructorBio ?? '',
                                  ),
                                ],
                                const SizedBox(height: AppSpacing.xxl),
                                CoursePricingSection(
                                  price: course.price ?? '',
                                  priceNote: course.priceNote ?? '',
                                  spotsAvailable: spotsAvailable,
                                  spotsTotal: spotsTotal,
                                  onRegister: course.registrationUrl != null
                                      ? () {}
                                      : null,
                                  onShare: () {},
                                  onSource: course.originalUrl != null
                                      ? () {}
                                      : null,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
