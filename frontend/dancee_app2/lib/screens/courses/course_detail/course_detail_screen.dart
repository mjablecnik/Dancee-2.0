import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';
import '../../../data/course_repository.dart';
import '../../../i18n/strings.g.dart';
import '../../../shared/elements/navigation/app_bottom_nav_bar.dart';
import '../../../shared/sections/description_section.dart';
import '../../../shared/sections/detail_header_section.dart';
import '../../../shared/sections/hero_image_section.dart';
import '../../../shared/sections/key_info_section.dart';
import 'sections/course_instructor_section.dart';
import 'sections/course_pricing_section.dart';
import 'sections/course_schedule_section.dart';
import 'sections/course_title_section.dart';

class CourseDetailScreen extends StatelessWidget {
  const CourseDetailScreen({super.key});

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
            child: FutureBuilder<CourseDetailData>(
              future: const CourseRepository().getCourseDetail('salsa-cubana'),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                final course = snapshot.data!;
                return SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    children: [
                      HeroImageSection(
                        imageUrl: course.imageUrl,
                        topLeft: HeroLabelBadge(label: course.levelLabel),
                        topRight: HeroPriceBadge(price: course.price),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: AppSpacing.xxl),
                            CourseTitleSection(
                              title: course.title,
                              styleChips: course.styleChips
                                  .map((c) => StyleChipData(label: c.label, color: c.color))
                                  .toList(),
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            KeyInfoSection(
                              items: course.keyInfo
                                  .map((k) => KeyInfoItem(
                                        icon: k.icon,
                                        title: k.title,
                                        subtitle: k.subtitle,
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            DescriptionSection(
                              title: t.courses.detail.description,
                              paragraphs: course.descriptionParagraphs,
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            CourseScheduleSection(
                              details: course.scheduleDetails
                                  .map((d) => ScheduleDetail(label: d.label, value: d.value))
                                  .toList(),
                              learningItems: course.learningItems,
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            CourseInstructorSection(
                              avatarUrl: course.instructorAvatarUrl,
                              name: course.instructorName,
                              bio: course.instructorBio,
                              stats: course.instructorStats
                                  .map((s) => InstructorStat(value: s.value, label: s.label))
                                  .toList(),
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            CoursePricingSection(
                              price: course.price,
                              priceNote: course.priceNote,
                              spotsAvailable: course.spotsAvailable,
                              spotsTotal: course.spotsTotal,
                              onRegister: () {},
                              onShare: () {},
                              onSource: () {},
                            ),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        fabIcon: FontAwesomeIcons.graduationCap,
        leftItems: [
          AppNavBarItem(
            icon: FontAwesomeIcons.house,
            label: t.nav.home,
            onTap: () => context.go('/events'),
          ),
          AppNavBarItem(
            icon: FontAwesomeIcons.magnifyingGlass,
            label: t.nav.search,
          ),
        ],
        rightItems: [
          AppNavBarItem(
            icon: FontAwesomeIcons.bookOpen,
            label: t.nav.courses,
            isActive: true,
            onTap: () => context.go('/courses'),
          ),
          AppNavBarItem(
            icon: FontAwesomeIcons.user,
            label: t.nav.profile,
          ),
        ],
      ),
    );
  }
}
