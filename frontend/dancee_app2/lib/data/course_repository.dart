import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../core/colors.dart';

// ─── Model classes ───────────────────────────────────────────────────────────

class CourseTagData {
  final String label;
  final Color color;

  const CourseTagData({required this.label, required this.color});
}

class FeaturedCourseData {
  final String id;
  final String imageUrl;
  final String levelLabel;
  final Color levelColor;
  final String title;
  final String instructor;
  final String dateRange;
  final String styleLabel;
  final Color styleColor;
  final String price;

  const FeaturedCourseData({
    required this.id,
    required this.imageUrl,
    required this.levelLabel,
    required this.levelColor,
    required this.title,
    required this.instructor,
    required this.dateRange,
    required this.styleLabel,
    required this.styleColor,
    required this.price,
  });
}

class CourseListData {
  final String id;
  final String imageUrl;
  final String title;
  final String instructor;
  final String dateRange;
  final List<CourseTagData> tags;
  final String price;

  const CourseListData({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.instructor,
    required this.dateRange,
    required this.tags,
    required this.price,
  });
}

class CourseKeyInfoData {
  final IconData icon;
  final String title;
  final String subtitle;

  const CourseKeyInfoData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class CourseScheduleDetailData {
  final String label;
  final String value;

  const CourseScheduleDetailData({required this.label, required this.value});
}

class CourseInstructorStatData {
  final String value;
  final String label;

  const CourseInstructorStatData({required this.value, required this.label});
}

class CourseStyleChipData {
  final String label;
  final Color color;

  const CourseStyleChipData({required this.label, required this.color});
}

class CourseDetailData {
  final String id;
  final String imageUrl;
  final String title;
  final String levelLabel;
  final String price;
  final List<CourseStyleChipData> styleChips;
  final List<CourseKeyInfoData> keyInfo;
  final List<String> descriptionParagraphs;
  final List<CourseScheduleDetailData> scheduleDetails;
  final List<String> learningItems;
  final String instructorAvatarUrl;
  final String instructorName;
  final String instructorBio;
  final List<CourseInstructorStatData> instructorStats;
  final String priceNote;
  final String spotsAvailable;
  final String spotsTotal;

  const CourseDetailData({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.levelLabel,
    required this.price,
    required this.styleChips,
    required this.keyInfo,
    required this.descriptionParagraphs,
    required this.scheduleDetails,
    required this.learningItems,
    required this.instructorAvatarUrl,
    required this.instructorName,
    required this.instructorBio,
    required this.instructorStats,
    required this.priceNote,
    required this.spotsAvailable,
    required this.spotsTotal,
  });
}

// ─── Repository ───────────────────────────────────────────────────────────────

class CourseRepository {
  const CourseRepository();

  Future<List<FeaturedCourseData>> getFeaturedCourses() async {
    return const [
      FeaturedCourseData(
        id: 'salsa-cubana',
        imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/b7b07c55da-1a5df97edf8c1ed85c9a.png',
        levelLabel: 'Začátečníci',
        levelColor: appPrimary,
        title: 'Salsa Cubana pro začátečníky',
        instructor: 'Dance Studio Praha',
        dateRange: '15. Led - 30. Dub 2025',
        styleLabel: 'Salsa',
        styleColor: appPrimary,
        price: '2 500 Kč',
      ),
      FeaturedCourseData(
        id: 'bachata-sensual',
        imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/5a2ccba7af-f45a64d9fa0f2acd8902.png',
        levelLabel: 'Pokročilí',
        levelColor: appAccent,
        title: 'Bachata Sensual Advanced',
        instructor: 'Carlos & Maria',
        dateRange: '1. Úno - 15. Kvě 2025',
        styleLabel: 'Bachata',
        styleColor: appAccent,
        price: '3 200 Kč',
      ),
    ];
  }

  Future<List<CourseListData>> getAllCourses() async {
    return const [
      CourseListData(
        id: 'kizomba-zacatecnici',
        imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/76f620736b-1b30838deee34bc8d92d.png',
        title: 'Kizomba pro začátečníky - Základy a technika',
        instructor: 'Dance Academy Brno',
        dateRange: '10. Led - 20. Bře 2025',
        tags: [CourseTagData(label: 'Kizomba', color: appLavender)],
        price: '1 800 Kč',
      ),
      CourseListData(
        id: 'zouk-intermediate',
        imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/7aea1ca5f9-df80ba7a33c40f0d747f.png',
        title: 'Zouk Brazilian - Intermediate Level',
        instructor: 'Rodrigo Silva',
        dateRange: '5. Úno - 25. Dub 2025',
        tags: [CourseTagData(label: 'Zouk', color: appTeal)],
        price: '2 900 Kč',
      ),
      CourseListData(
        id: 'salsa-on2',
        imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/a7cd619a31-3615d5bebdd9530c56ad.png',
        title: 'Salsa On2 New York Style - Pokročilí tanečníci',
        instructor: 'Taneční škola Ritmo',
        dateRange: '1. Bře - 30. Kvě 2025',
        tags: [CourseTagData(label: 'Salsa', color: appPrimary)],
        price: '3 500 Kč',
      ),
      CourseListData(
        id: 'bachata-dominicana',
        imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/6ade0c4c2f-6feddb3834ecd06ea480.png',
        title: 'Bachata Dominicana - Autentický styl',
        instructor: 'Latino Dance Studio',
        dateRange: '12. Led - 28. Bře 2025',
        tags: [CourseTagData(label: 'Bachata', color: appAccent)],
        price: '2 400 Kč',
      ),
      CourseListData(
        id: 'west-coast-swing',
        imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/63212152d8-4a9271e50d1f29074c57.png',
        title: 'West Coast Swing - Základní kurz',
        instructor: 'Swing Time Praha',
        dateRange: '8. Úno - 15. Kvě 2025',
        tags: [CourseTagData(label: 'Swing', color: appGold)],
        price: '2 700 Kč',
      ),
      CourseListData(
        id: 'salsa-bachata-combo',
        imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/948f834bc0-ab80b9f7f0c22452d82b.png',
        title: 'Salsa & Bachata Combo - Intenzivní víkendový kurz',
        instructor: 'Dance Fusion Ostrava',
        dateRange: '25. Led - 26. Led 2025',
        tags: [
          CourseTagData(label: 'Salsa', color: appPrimary),
          CourseTagData(label: 'Bachata', color: appAccent),
        ],
        price: '1 200 Kč',
      ),
    ];
  }

  Future<CourseDetailData> getCourseDetail(String id) async {
    return const CourseDetailData(
      id: 'salsa-cubana',
      imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/0044a4f9d3-b46f198ea48e475a16aa.png',
      title: 'Salsa Cubana pro začátečníky',
      levelLabel: 'Začátečníci',
      price: '2 500 Kč',
      styleChips: [
        CourseStyleChipData(label: 'Salsa', color: appPrimary),
      ],
      keyInfo: [
        CourseKeyInfoData(
          icon: FontAwesomeIcons.calendar,
          title: '15. Leden - 30. Duben 2025',
          subtitle: 'Každé úterý 19:00 - 20:30',
        ),
        CourseKeyInfoData(
          icon: FontAwesomeIcons.locationDot,
          title: 'Dance Studio Praha',
          subtitle: 'Wenceslas Square 14, Praha 1',
        ),
        CourseKeyInfoData(
          icon: FontAwesomeIcons.userTie,
          title: 'Carlos Rodriguez',
          subtitle: 'Certifikovaný lektor salsy',
        ),
        CourseKeyInfoData(
          icon: FontAwesomeIcons.tag,
          title: '2 500 Kč',
          subtitle: 'Za celý kurz (15 lekcí)',
        ),
      ],
      descriptionParagraphs: [
        'Objevte krásu kubánské salsy v našem kurzu určeném pro úplné začátečníky. Naučíte se základní kroky, rytmus a techniky, které vám umožní tancovat s jistotou na jakékoli taneční akci.',
        'Kurz je veden zkušeným lektorem Carlosem Rodriguezem, který má více než 10 let zkušeností s výukou latinsko-amerických tanců. Každá lekce je strukturovaná tak, aby postupně budovala vaše dovednosti.',
        'Žádné předchozí zkušenosti nejsou potřeba. Přijďte si užít skvělou atmosféru a poznat nové přátele!',
      ],
      scheduleDetails: [
        CourseScheduleDetailData(label: 'Délka kurzu', value: '15 lekcí'),
        CourseScheduleDetailData(label: 'Délka lekce', value: '90 minut'),
        CourseScheduleDetailData(label: 'Maximální počet', value: '20 osob'),
        CourseScheduleDetailData(label: 'Úroveň', value: 'Začátečníci'),
        CourseScheduleDetailData(label: 'Věková skupina', value: '18+ let'),
      ],
      learningItems: [
        'Základní kroky kubánské salsy',
        'Rytmus a timing v salse',
        'Základní otočky a figury',
        'Vedení a následování partnera',
        'Taneční etiketa a sociální tanec',
      ],
      instructorAvatarUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/avatars/avatar-8.jpg',
      instructorName: 'Carlos Rodriguez',
      instructorBio: 'Profesionální tanečník a lektor s více než 10 let zkušeností. Specializuje se na kubánskou salsu a bachatu. Vyučoval v prestižních studiích po celé Evropě.',
      instructorStats: [
        CourseInstructorStatData(value: '10+', label: 'let zkušeností'),
        CourseInstructorStatData(value: '500+', label: 'studentů'),
      ],
      priceNote: 'Platba na místě nebo převodem',
      spotsAvailable: '12',
      spotsTotal: '20',
    );
  }
}
