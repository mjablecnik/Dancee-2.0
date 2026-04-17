import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';
import '../../../data/event_repository.dart' as repo;
import '../../../i18n/strings.g.dart';
import '../../../shared/elements/navigation/app_bottom_nav_bar.dart';
import '../../../shared/sections/description_section.dart';
import '../../../shared/sections/detail_header_section.dart';
import '../../../shared/sections/hero_image_section.dart';
import '../../../shared/sections/key_info_section.dart';
import 'sections/action_buttons_section.dart';
import 'sections/additional_info_section.dart';
import 'sections/event_program_section.dart';
import 'sections/event_title_section.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      body: Column(
        children: [
          DetailHeaderSection(
            title: t.events.detail.header,
            onBack: () => context.pop(),
          ),
          Expanded(
            child: FutureBuilder<repo.EventDetailData>(
              future: const repo.EventRepository().getEventDetail('prague-latin-festival-2025'),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                final event = snapshot.data!;
                return SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    children: [
                      HeroImageSection(
                        imageUrl: event.imageUrl,
                        topLeft: HeroPriceBadge(price: event.price),
                        topRight: HeroFavoriteButton(
                          isFavorite: event.isFavorite,
                          onTap: () {},
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: AppSpacing.xxl),
                            EventTitleSection(
                              title: event.title,
                              chips: event.chips
                                  .map((c) => EventTitleChip(label: c.label, color: c.color))
                                  .toList(),
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            KeyInfoSection(
                              items: event.keyInfo
                                  .map((k) => KeyInfoItem(
                                        icon: k.icon,
                                        title: k.title,
                                        subtitle: k.subtitle,
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            ActionButtonsSection(
                              onSave: () {},
                              onShare: () {},
                              onMap: () {},
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            DescriptionSection(
                              title: t.events.detail.description,
                              paragraphs: event.descriptionParagraphs,
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            AdditionalInfoSection(
                              priceRange: event.priceRange,
                              dresscode: event.dresscode,
                              onBuyTickets: () {},
                              onSource: () {},
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            EventProgramSection(
                              days: event.program
                                  .map((d) => ProgramDayData(
                                        day: d.day,
                                        slots: d.slots
                                            .map((s) => ProgramSlotData(
                                                  time: s.time,
                                                  title: s.title,
                                                  description: s.description,
                                                  extra: s.extra,
                                                  extraColor: s.extraColor,
                                                ))
                                            .toList(),
                                      ))
                                  .toList(),
                            ),
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
            icon: FontAwesomeIcons.solidHeart,
            label: t.nav.saved,
            isActive: true,
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
