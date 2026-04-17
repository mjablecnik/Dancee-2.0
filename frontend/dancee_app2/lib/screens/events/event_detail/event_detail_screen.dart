import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';
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
            title: 'Detail akce',
            onBack: () => context.pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  HeroImageSection(
                    imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/1887dced68-d1676f788ddb2c7f66cf.png',
                    topLeft: const HeroPriceBadge(price: 'Od 350 Kč'),
                    topRight: HeroFavoriteButton(
                      isFavorite: true,
                      onTap: () {},
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.xxl),
                        const EventTitleSection(
                          title: 'Prague Latin Festival 2025 - Mega Edition',
                          chips: [
                            EventTitleChip(label: 'Salsa', color: appPrimary),
                            EventTitleChip(label: 'Bachata', color: appAccent),
                            EventTitleChip(label: 'Zouk', color: appTeal),
                            EventTitleChip(label: 'Kizomba', color: appLavender),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        const KeyInfoSection(
                          items: [
                            KeyInfoItem(
                              icon: FontAwesomeIcons.calendar,
                              title: '12. Říjen - 14. Říjen 2025',
                              subtitle: 'Pátek 18:00 - Neděle 02:00',
                            ),
                            KeyInfoItem(
                              icon: FontAwesomeIcons.locationDot,
                              title: 'Kongresové centrum Praha',
                              subtitle: '5. května 65, Praha 4',
                            ),
                            KeyInfoItem(
                              icon: FontAwesomeIcons.userTie,
                              title: 'Prague Latin Events',
                              subtitle: 'Organizátor',
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        ActionButtonsSection(
                          onSave: () {},
                          onShare: () {},
                          onMap: () {},
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        const DescriptionSection(
                          title: 'Popis akce',
                          paragraphs: [
                            'Největší latinsko-americký taneční festival v České republice se vrací! Tři dny plné workshopů s mezinárodními lektory, sociálních tanečních večírků a nezapomenutelné atmosféry.',
                            'Připravte se na intenzivní víkend plný tance, kde se setkáte s nejlepšími tanečníky a lektory z celého světa. Festival nabízí workshopy pro všechny úrovně - od začátečníků až po pokročilé tanečníky.',
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        AdditionalInfoSection(
                          priceRange: '350 - 1200 Kč',
                          dresscode: 'Elegantní casual',
                          onBuyTickets: () {},
                          onSource: () {},
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        EventProgramSection(
                          days: const [
                            ProgramDayData(
                              day: 'Pátek 12. Říjen',
                              slots: [
                                ProgramSlotData(
                                  time: '18:00',
                                  title: 'Registrace a Welcome drink',
                                  description: 'Uvítací nápoj a seznámení',
                                ),
                                ProgramSlotData(
                                  time: '20:00',
                                  title: 'Opening Party',
                                  description: 'Úvodní taneční večírek',
                                  extra: 'DJ: Carlos Rodriguez',
                                  extraColor: appPrimary,
                                ),
                              ],
                            ),
                            ProgramDayData(
                              day: 'Sobota 13. Říjen',
                              slots: [
                                ProgramSlotData(
                                  time: '10:00',
                                  title: 'Salsa Workshop - Začátečníci',
                                  description: 'Základy salsy pro nové tanečníky',
                                  extra: 'Lektoři: Maria & José Santos',
                                  extraColor: appAccent,
                                ),
                                ProgramSlotData(
                                  time: '12:00',
                                  title: 'Bachata Sensual Workshop',
                                  description: 'Pokročilé techniky bachaty sensual',
                                  extra: 'Lektoři: Korke & Judith',
                                  extraColor: appAccent,
                                ),
                                ProgramSlotData(
                                  time: '21:00',
                                  title: 'Saturday Night Fever',
                                  description: 'Hlavní taneční večírek',
                                  extra: 'DJ: Alex Sensation, DJ Tumbao',
                                  extraColor: appPrimary,
                                ),
                              ],
                            ),
                            ProgramDayData(
                              day: 'Neděle 14. Říjen',
                              slots: [
                                ProgramSlotData(
                                  time: '11:00',
                                  title: 'Kizomba & Tarraxinha',
                                  description: 'Intenzivní workshop kizomby',
                                  extra: 'Lektoři: Moun & Seraphine',
                                  extraColor: appAccent,
                                ),
                                ProgramSlotData(
                                  time: '14:00',
                                  title: 'Closing Social',
                                  description: 'Závěrečný taneční social',
                                  extra: 'DJ: Local Heroes',
                                  extraColor: appPrimary,
                                ),
                              ],
                            ),
                          ],
                        ),
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
            icon: FontAwesomeIcons.solidHeart,
            label: 'Uložené',
            isActive: true,
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
