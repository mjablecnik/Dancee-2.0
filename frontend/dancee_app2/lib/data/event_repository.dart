import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../core/colors.dart';

// ─── Model classes ───────────────────────────────────────────────────────────

class EventTagData {
  final String label;
  final Color color;

  const EventTagData({required this.label, required this.color});
}

class FeaturedEventData {
  final String id;
  final String imageUrl;
  final String title;
  final String date;
  final String location;
  final String price;
  final bool isFree;
  final bool isFavorited;
  final List<EventTagData> tags;

  const FeaturedEventData({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.date,
    required this.location,
    required this.price,
    required this.isFree,
    required this.isFavorited,
    required this.tags,
  });
}

class UpcomingEventData {
  final String id;
  final String imageUrl;
  final String title;
  final String location;
  final String date;
  final List<EventTagData> tags;
  final bool isFavorited;

  const UpcomingEventData({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.date,
    required this.tags,
    required this.isFavorited,
  });
}

class EventChipData {
  final String label;
  final Color color;

  const EventChipData({required this.label, required this.color});
}

class EventKeyInfoData {
  final IconData icon;
  final String title;
  final String subtitle;

  const EventKeyInfoData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class ProgramSlotData {
  final String time;
  final String title;
  final String description;
  final String? extra;
  final Color? extraColor;

  const ProgramSlotData({
    required this.time,
    required this.title,
    required this.description,
    this.extra,
    this.extraColor,
  });
}

class ProgramDayData {
  final String day;
  final List<ProgramSlotData> slots;

  const ProgramDayData({required this.day, required this.slots});
}

class EventDetailData {
  final String id;
  final String imageUrl;
  final String title;
  final String price;
  final bool isFavorite;
  final List<EventChipData> chips;
  final List<EventKeyInfoData> keyInfo;
  final List<String> descriptionParagraphs;
  final String priceRange;
  final String dresscode;
  final List<ProgramDayData> program;

  const EventDetailData({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.isFavorite,
    required this.chips,
    required this.keyInfo,
    required this.descriptionParagraphs,
    required this.priceRange,
    required this.dresscode,
    required this.program,
  });
}

class DanceStyleData {
  final String name;
  final String subtitle;
  final IconData icon;
  final Color gradientStart;
  final Color gradientEnd;

  const DanceStyleData({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.gradientStart,
    required this.gradientEnd,
  });
}

class OnboardingDanceStyle {
  final IconData icon;
  final String name;

  const OnboardingDanceStyle({required this.icon, required this.name});
}

class ExperienceLevelData {
  final IconData icon;
  final Color iconColor;
  final String name;
  final String description;

  const ExperienceLevelData({
    required this.icon,
    required this.iconColor,
    required this.name,
    required this.description,
  });
}

// ─── Repository ───────────────────────────────────────────────────────────────

class EventRepository {
  const EventRepository();

  Future<List<FeaturedEventData>> getFeaturedEvents() async {
    return const [
      FeaturedEventData(
        id: 'prague-latin-festival-2025',
        imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/1887dced68-753b152bd32ad7f3eb9b.png',
        title: 'Prague Latin Festival 2025 - Mega Edition',
        date: '12. Říj - 14. Říj 2025',
        location: 'Kongresové centrum, Praha',
        price: 'Od 350 Kč',
        isFree: false,
        isFavorited: false,
        tags: [
          EventTagData(label: 'Salsa', color: appPrimary),
          EventTagData(label: 'Bachata', color: appAccent),
        ],
      ),
      FeaturedEventData(
        id: 'kizomba-open-air',
        imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/35e8621ce9-d463887a55ba17b5c416.png',
        title: 'Kizomba Open Air Social',
        date: 'Dnes, 18:00 - 23:00',
        location: 'Střelecký ostrov, Praha',
        price: 'Zdarma',
        isFree: true,
        isFavorited: true,
        tags: [
          EventTagData(label: 'Kizomba', color: appLavender),
          EventTagData(label: 'Semba', color: appLightBlue),
        ],
      ),
      FeaturedEventData(
        id: 'zouk-congress-prague',
        imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/858406cadf-a18221d3c2f7fc2a6f2a.png',
        title: 'Zouk Congress Prague 2025',
        date: '1. Lis - 3. Lis 2025',
        location: 'Hotel Pyramida, Praha',
        price: 'Od 500 Kč',
        isFree: false,
        isFavorited: false,
        tags: [
          EventTagData(label: 'Zouk', color: appTeal),
          EventTagData(label: 'Lambada', color: appEmerald),
        ],
      ),
      FeaturedEventData(
        id: 'tango-milonga-night',
        imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/a7414ef4de-19550fae1cabebe15c09.png',
        title: 'Tango Milonga Night',
        date: '25. Říj, 20:00',
        location: 'Palác Akropolis, Praha',
        price: '150 Kč',
        isFree: false,
        isFavorited: false,
        tags: [
          EventTagData(label: 'Tango', color: appGold),
        ],
      ),
      FeaturedEventData(
        id: 'swing-garden-party',
        imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/9d038750ea-18e3a1b3f78567f6cc57.png',
        title: 'Swing Garden Party - Live Band',
        date: '28. Říj, 17:00',
        location: 'Riegrovy sady, Praha',
        price: 'Zdarma',
        isFree: true,
        isFavorited: false,
        tags: [
          EventTagData(label: 'Swing', color: appCyan),
          EventTagData(label: 'Lindy Hop', color: appPrimary),
        ],
      ),
    ];
  }

  Future<List<UpcomingEventData>> getUpcomingEvents() async {
    return const [
      UpcomingEventData(
        id: 'bachata-sensual-workshop',
        imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/a7414ef4de-19550fae1cabebe15c09.png',
        title: 'Bachata Sensual Workshop s mezinárodními lektory',
        location: 'Dance Studio 1, Brno',
        date: '20. Říj, 14:00',
        tags: [
          EventTagData(label: 'Bachata', color: appAccent),
          EventTagData(label: 'Sensual', color: appPink),
        ],
        isFavorited: false,
      ),
      UpcomingEventData(
        id: 'havana-night',
        imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/9d038750ea-18e3a1b3f78567f6cc57.png',
        title: 'Havana Night - Živá kapela a animace',
        location: 'Klub Tres, Ostrava',
        date: '22. Říj, 20:00',
        tags: [
          EventTagData(label: 'Salsa', color: appPrimary),
          EventTagData(label: 'Bachata', color: appAccent),
          EventTagData(label: 'Kizomba', color: appLavender),
        ],
        isFavorited: true,
      ),
      UpcomingEventData(
        id: 'zouk-weekend-marathon',
        imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/858406cadf-a18221d3c2f7fc2a6f2a.png',
        title: 'Zouk Weekend Marathon 2025',
        location: 'Hotel Pyramida, Praha',
        date: '1. Lis - 3. Lis',
        tags: [
          EventTagData(label: 'Zouk', color: appTeal),
          EventTagData(label: 'Lambada', color: appEmerald),
        ],
        isFavorited: false,
      ),
    ];
  }

  Future<EventDetailData> getEventDetail(String id) async {
    return const EventDetailData(
      id: 'prague-latin-festival-2025',
      imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/1887dced68-d1676f788ddb2c7f66cf.png',
      title: 'Prague Latin Festival 2025 - Mega Edition',
      price: 'Od 350 Kč',
      isFavorite: true,
      chips: [
        EventChipData(label: 'Salsa', color: appPrimary),
        EventChipData(label: 'Bachata', color: appAccent),
        EventChipData(label: 'Zouk', color: appTeal),
        EventChipData(label: 'Kizomba', color: appLavender),
      ],
      keyInfo: [
        EventKeyInfoData(
          icon: FontAwesomeIcons.calendar,
          title: '12. Říjen - 14. Říjen 2025',
          subtitle: 'Pátek 18:00 - Neděle 02:00',
        ),
        EventKeyInfoData(
          icon: FontAwesomeIcons.locationDot,
          title: 'Kongresové centrum Praha',
          subtitle: '5. května 65, Praha 4',
        ),
        EventKeyInfoData(
          icon: FontAwesomeIcons.userTie,
          title: 'Prague Latin Events',
          subtitle: 'Organizátor',
        ),
      ],
      descriptionParagraphs: [
        'Největší latinsko-americký taneční festival v České republice se vrací! Tři dny plné workshopů s mezinárodními lektory, sociálních tanečních večírků a nezapomenutelné atmosféry.',
        'Připravte se na intenzivní víkend plný tance, kde se setkáte s nejlepšími tanečníky a lektory z celého světa. Festival nabízí workshopy pro všechny úrovně - od začátečníků až po pokročilé tanečníky.',
      ],
      priceRange: '350 - 1200 Kč',
      dresscode: 'Elegantní casual',
      program: [
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
    );
  }

  Future<List<DanceStyleData>> getDanceStyles() async {
    return const [
      DanceStyleData(
        name: 'Salsa',
        subtitle: 'Kubánská, On1, On2',
        icon: FontAwesomeIcons.music,
        gradientStart: appPrimary,
        gradientEnd: appPrimaryDark,
      ),
      DanceStyleData(
        name: 'Bachata',
        subtitle: 'Sensual, Dominicana',
        icon: FontAwesomeIcons.heart,
        gradientStart: appAccent,
        gradientEnd: appPink,
      ),
      DanceStyleData(
        name: 'Kizomba',
        subtitle: 'Urban Kiz, Semba',
        icon: FontAwesomeIcons.fire,
        gradientStart: appViolet,
        gradientEnd: appVioletDark,
      ),
      DanceStyleData(
        name: 'Zouk',
        subtitle: 'Brazilian Zouk, Lambada',
        icon: FontAwesomeIcons.leaf,
        gradientStart: appEmerald,
        gradientEnd: appSuccessDark,
      ),
      DanceStyleData(
        name: 'Reggaeton',
        subtitle: 'Urban Latin',
        icon: FontAwesomeIcons.fireFlameSimple,
        gradientStart: appWarning,
        gradientEnd: appError,
      ),
      DanceStyleData(
        name: 'Tango',
        subtitle: 'Argentinské, Ballroom',
        icon: FontAwesomeIcons.bolt,
        gradientStart: appYellow,
        gradientEnd: appAmberDark,
      ),
      DanceStyleData(
        name: 'Swing',
        subtitle: 'Lindy Hop, Charleston',
        icon: FontAwesomeIcons.crown,
        gradientStart: appCyan,
        gradientEnd: appPrimary,
      ),
      DanceStyleData(
        name: 'Ballroom',
        subtitle: 'Standardní, Latinsko-americké',
        icon: FontAwesomeIcons.star,
        gradientStart: appPink,
        gradientEnd: appRose,
      ),
      DanceStyleData(
        name: 'Afro',
        subtitle: 'Afrohouse, Kuduro',
        icon: FontAwesomeIcons.drum,
        gradientStart: appIndigo,
        gradientEnd: appPurple,
      ),
      DanceStyleData(
        name: 'Forró',
        subtitle: 'Brazilský lidový tanec',
        icon: FontAwesomeIcons.umbrellaBeach,
        gradientStart: appError,
        gradientEnd: appHotPink,
      ),
    ];
  }

  Future<List<OnboardingDanceStyle>> getOnboardingDanceStyles() async {
    return const [
      OnboardingDanceStyle(icon: FontAwesomeIcons.fire, name: 'Salsa'),
      OnboardingDanceStyle(icon: FontAwesomeIcons.heart, name: 'Bachata'),
      OnboardingDanceStyle(icon: FontAwesomeIcons.water, name: 'Zouk'),
      OnboardingDanceStyle(icon: FontAwesomeIcons.moon, name: 'Kizomba'),
      OnboardingDanceStyle(icon: FontAwesomeIcons.spa, name: 'Tango'),
      OnboardingDanceStyle(icon: FontAwesomeIcons.music, name: 'Swing'),
      OnboardingDanceStyle(icon: FontAwesomeIcons.bolt, name: 'Hip Hop'),
      OnboardingDanceStyle(icon: FontAwesomeIcons.star, name: 'Jiné'),
    ];
  }

  Future<List<String>> getDanceStyleFilters() async {
    return const ['Vše', 'Salsa', 'Bachata', 'Kizomba', 'Zouk'];
  }

  Future<List<String>> getCourseStyleFilters() async {
    return const ['Vše', 'Salsa', 'Bachata', 'Kizomba', 'Zouk', 'Swing'];
  }

  Future<List<UpcomingEventData>> getSavedEvents() async {
    return const [
      UpcomingEventData(
        id: 'kizomba-open-air',
        imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/35e8621ce9-d463887a55ba17b5c416.png',
        title: 'Kizomba Open Air Social',
        location: 'Střelecký ostrov, Praha',
        date: 'Dnes, 18:00 - 23:00',
        tags: [
          EventTagData(label: 'Kizomba', color: appLavender),
          EventTagData(label: 'Semba', color: appLightBlue),
        ],
        isFavorited: true,
      ),
      UpcomingEventData(
        id: 'havana-night',
        imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/9d038750ea-18e3a1b3f78567f6cc57.png',
        title: 'Havana Night - Živá kapela a animace',
        location: 'Klub Tres, Ostrava',
        date: '22. Říj, 20:00',
        tags: [
          EventTagData(label: 'Salsa', color: appPrimary),
          EventTagData(label: 'Bachata', color: appAccent),
        ],
        isFavorited: true,
      ),
      UpcomingEventData(
        id: 'bachata-sensual-workshop',
        imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/a7414ef4de-19550fae1cabebe15c09.png',
        title: 'Bachata Sensual Workshop s mezinárodními lektory',
        location: 'Dance Studio 1, Brno',
        date: '20. Říj, 14:00',
        tags: [
          EventTagData(label: 'Bachata', color: appAccent),
          EventTagData(label: 'Sensual', color: appPink),
        ],
        isFavorited: true,
      ),
    ];
  }

  Future<List<ExperienceLevelData>> getExperienceLevels() async {
    return const [
      ExperienceLevelData(
        icon: FontAwesomeIcons.seedling,
        iconColor: appSuccess,
        name: 'Začátečník',
        description: 'Teprve začínám s tancem',
      ),
      ExperienceLevelData(
        icon: FontAwesomeIcons.chartLine,
        iconColor: appPrimary,
        name: 'Mírně pokročilý',
        description: 'Mám základní zkušenosti',
      ),
      ExperienceLevelData(
        icon: FontAwesomeIcons.fire,
        iconColor: appAccent,
        name: 'Pokročilý',
        description: 'Tančím pravidelně několik let',
      ),
      ExperienceLevelData(
        icon: FontAwesomeIcons.crown,
        iconColor: appYellow,
        name: 'Expert',
        description: 'Profesionální úroveň',
      ),
    ];
  }
}
