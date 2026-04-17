import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/colors.dart';
import '../../core/theme.dart';
import '../../shared/elements/navigation/app_bottom_nav_bar.dart';
import '../../shared/sections/description_section.dart';
import '../../shared/sections/detail_header_section.dart';
import '../../shared/sections/hero_image_section.dart';
import '../../shared/sections/key_info_section.dart';
import 'course_detail/sections/course_instructor_section.dart';
import 'course_detail/sections/course_pricing_section.dart';
import 'course_detail/sections/course_schedule_section.dart';
import 'course_detail/sections/course_title_section.dart';

class CourseDetailScreen extends StatelessWidget {
  const CourseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      body: Column(
        children: [
          DetailHeaderSection(
            title: 'Detail kurzu',
            onBack: () => context.pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  HeroImageSection(
                    imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/0044a4f9d3-b46f198ea48e475a16aa.png',
                    topLeft: const HeroLabelBadge(label: 'Začátečníci'),
                    topRight: const HeroPriceBadge(price: '2 500 Kč'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.xxl),
                        const CourseTitleSection(
                          title: 'Salsa Cubana pro začátečníky',
                          styleChips: [
                            StyleChipData(label: 'Salsa', color: appPrimary),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        const KeyInfoSection(
                          items: [
                            KeyInfoItem(
                              icon: FontAwesomeIcons.calendar,
                              title: '15. Leden - 30. Duben 2025',
                              subtitle: 'Každé úterý 19:00 - 20:30',
                            ),
                            KeyInfoItem(
                              icon: FontAwesomeIcons.locationDot,
                              title: 'Dance Studio Praha',
                              subtitle: 'Wenceslas Square 14, Praha 1',
                            ),
                            KeyInfoItem(
                              icon: FontAwesomeIcons.userTie,
                              title: 'Carlos Rodriguez',
                              subtitle: 'Certifikovaný lektor salsy',
                            ),
                            KeyInfoItem(
                              icon: FontAwesomeIcons.tag,
                              title: '2 500 Kč',
                              subtitle: 'Za celý kurz (15 lekcí)',
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        const DescriptionSection(
                          title: 'Popis kurzu',
                          paragraphs: [
                            'Objevte krásu kubánské salsy v našem kurzu určeném pro úplné začátečníky. Naučíte se základní kroky, rytmus a techniky, které vám umožní tancovat s jistotou na jakékoli taneční akci.',
                            'Kurz je veden zkušeným lektorem Carlosem Rodriguezem, který má více než 10 let zkušeností s výukou latinsko-amerických tanců. Každá lekce je strukturovaná tak, aby postupně budovala vaše dovednosti.',
                            'Žádné předchozí zkušenosti nejsou potřeba. Přijďte si užít skvělou atmosféru a poznat nové přátele!',
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        const CourseScheduleSection(
                          details: [
                            ScheduleDetail(label: 'Délka kurzu', value: '15 lekcí'),
                            ScheduleDetail(label: 'Délka lekce', value: '90 minut'),
                            ScheduleDetail(label: 'Maximální počet', value: '20 osob'),
                            ScheduleDetail(label: 'Úroveň', value: 'Začátečníci'),
                            ScheduleDetail(label: 'Věková skupina', value: '18+ let'),
                          ],
                          learningItems: [
                            'Základní kroky kubánské salsy',
                            'Rytmus a timing v salse',
                            'Základní otočky a figury',
                            'Vedení a následování partnera',
                            'Taneční etiketa a sociální tanec',
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        const CourseInstructorSection(
                          avatarUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/avatars/avatar-8.jpg',
                          name: 'Carlos Rodriguez',
                          bio: 'Profesionální tanečník a lektor s více než 10 let zkušeností. Specializuje se na kubánskou salsu a bachatu. Vyučoval v prestižních studiích po celé Evropě.',
                          stats: [
                            InstructorStat(value: '10+', label: 'let zkušeností'),
                            InstructorStat(value: '500+', label: 'studentů'),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        CoursePricingSection(
                          price: '2 500 Kč',
                          priceNote: 'Platba na místě nebo převodem',
                          spotsAvailable: '12',
                          spotsTotal: '20',
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
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        fabIcon: FontAwesomeIcons.graduationCap,
        leftItems: [
          AppNavBarItem(
            icon: FontAwesomeIcons.house,
            label: 'Domů',
            onTap: () => context.go('/events'),
          ),
          AppNavBarItem(
            icon: FontAwesomeIcons.magnifyingGlass,
            label: 'Hledat',
          ),
        ],
        rightItems: [
          AppNavBarItem(
            icon: FontAwesomeIcons.bookOpen,
            label: 'Kurzy',
            isActive: true,
            onTap: () => context.go('/courses'),
          ),
          AppNavBarItem(
            icon: FontAwesomeIcons.user,
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
