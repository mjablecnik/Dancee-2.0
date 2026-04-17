import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/colors.dart';

class CoursesListScreen extends StatefulWidget {
  const CoursesListScreen({super.key});

  @override
  State<CoursesListScreen> createState() => _CoursesListScreenState();
}

class _CoursesListScreenState extends State<CoursesListScreen> {
  int _selectedStyleIndex = 0;
  final List<String> _styles = ['Vše', 'Salsa', 'Bachata', 'Kizomba', 'Zouk', 'Swing'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 96, top: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDanceStylesFilter(),
                  const SizedBox(height: 24),
                  _buildFeaturedCourses(),
                  const SizedBox(height: 24),
                  _buildAllCourses(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: appBg.withValues(alpha: 0.9),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: appBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Taneční kurzy',
                style: TextStyle(
                  color: appText,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Najdi svůj kurz',
                style: TextStyle(
                  color: appMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: appSurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: FaIcon(FontAwesomeIcons.sliders, size: 18, color: appText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDanceStylesFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'TANEČNÍ STYLY',
            style: TextStyle(
              color: appMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: List.generate(_styles.length, (index) {
              final isActive = _selectedStyleIndex == index;
              return Padding(
                padding: EdgeInsets.only(right: index < _styles.length - 1 ? 8 : 0),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedStyleIndex = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isActive ? appPrimary : appSurface,
                      border: Border.all(color: isActive ? appPrimary : appBorder),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: isActive
                          ? [BoxShadow(color: appPrimary.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: -5)]
                          : null,
                    ),
                    child: Text(
                      _styles[index],
                      style: TextStyle(
                        color: isActive ? Colors.white : appText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCourses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Doporučené kurzy',
                style: TextStyle(color: appText, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Zobrazit vše',
                  style: TextStyle(color: appMuted, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _featuredCourseCard(
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
              const SizedBox(width: 16),
              _featuredCourseCard(
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _featuredCourseCard({
    required String imageUrl,
    required String levelLabel,
    required Color levelColor,
    required String title,
    required String instructor,
    required String dateRange,
    required String styleLabel,
    required Color styleColor,
    required String price,
  }) {
    return GestureDetector(
      onTap: () => context.go('/course-detail'),
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: appCard,
          border: Border.all(color: appBorder),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    imageUrl,
                    height: 140,
                    width: 280,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                          appCard,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: levelColor.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      levelLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: appText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.userTie, size: 14, color: appPrimary),
                      const SizedBox(width: 8),
                      Text(instructor, style: const TextStyle(color: appMuted, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.calendar, size: 14, color: appMuted),
                      const SizedBox(width: 8),
                      Text(dateRange, style: const TextStyle(color: appMuted, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: appSurface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          styleLabel,
                          style: TextStyle(
                            color: styleColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        price,
                        style: const TextStyle(
                          color: appText,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllCourses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Všechny kurzy',
                style: TextStyle(color: appText, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: appSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    FaIcon(FontAwesomeIcons.arrowUpWideShort, size: 14, color: appText),
                    SizedBox(width: 8),
                    Text('Datum', style: TextStyle(color: appText, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _courseListItem(
                imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/76f620736b-1b30838deee34bc8d92d.png',
                title: 'Kizomba pro začátečníky - Základy a technika',
                instructor: 'Dance Academy Brno',
                dateRange: '10. Led - 20. Bře 2025',
                styleLabel: 'Kizomba',
                styleColor: const Color(0xFFC084FC),
                price: '1 800 Kč',
              ),
              const SizedBox(height: 12),
              _courseListItem(
                imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/7aea1ca5f9-df80ba7a33c40f0d747f.png',
                title: 'Zouk Brazilian - Intermediate Level',
                instructor: 'Rodrigo Silva',
                dateRange: '5. Úno - 25. Dub 2025',
                styleLabel: 'Zouk',
                styleColor: const Color(0xFF34D399),
                price: '2 900 Kč',
              ),
              const SizedBox(height: 12),
              _courseListItem(
                imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/a7cd619a31-3615d5bebdd9530c56ad.png',
                title: 'Salsa On2 New York Style - Pokročilí tanečníci',
                instructor: 'Taneční škola Ritmo',
                dateRange: '1. Bře - 30. Kvě 2025',
                styleLabel: 'Salsa',
                styleColor: appPrimary,
                price: '3 500 Kč',
              ),
              const SizedBox(height: 12),
              _courseListItem(
                imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/6ade0c4c2f-6feddb3834ecd06ea480.png',
                title: 'Bachata Dominicana - Autentický styl',
                instructor: 'Latino Dance Studio',
                dateRange: '12. Led - 28. Bře 2025',
                styleLabel: 'Bachata',
                styleColor: appAccent,
                price: '2 400 Kč',
              ),
              const SizedBox(height: 12),
              _courseListItem(
                imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/63212152d8-4a9271e50d1f29074c57.png',
                title: 'West Coast Swing - Základní kurz',
                instructor: 'Swing Time Praha',
                dateRange: '8. Úno - 15. Kvě 2025',
                styleLabel: 'Swing',
                styleColor: const Color(0xFFFACC15),
                price: '2 700 Kč',
              ),
              const SizedBox(height: 12),
              _courseListItemMultiTag(
                imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/948f834bc0-ab80b9f7f0c22452d82b.png',
                title: 'Salsa & Bachata Combo - Intenzivní víkendový kurz',
                instructor: 'Dance Fusion Ostrava',
                dateRange: '25. Led - 26. Led 2025',
                tags: [
                  _TagData('Salsa', appPrimary),
                  _TagData('Bachata', appAccent),
                ],
                price: '1 200 Kč',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _courseListItem({
    required String imageUrl,
    required String title,
    required String instructor,
    required String dateRange,
    required String styleLabel,
    required Color styleColor,
    required String price,
  }) {
    return GestureDetector(
      onTap: () => context.go('/course-detail'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: appSurface,
          border: Border.all(color: appBorder),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: appText,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const FaIcon(FontAwesomeIcons.userTie, size: 12, color: appPrimary),
                          const SizedBox(width: 6),
                          Text(
                            instructor,
                            style: const TextStyle(color: appMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const FaIcon(FontAwesomeIcons.calendar, size: 12, color: appMuted),
                const SizedBox(width: 8),
                Text(dateRange, style: const TextStyle(color: appMuted, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: appCard,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    styleLabel,
                    style: TextStyle(
                      color: styleColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  price,
                  style: const TextStyle(
                    color: appText,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _courseListItemMultiTag({
    required String imageUrl,
    required String title,
    required String instructor,
    required String dateRange,
    required List<_TagData> tags,
    required String price,
  }) {
    return GestureDetector(
      onTap: () => context.go('/course-detail'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: appSurface,
          border: Border.all(color: appBorder),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: appText,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const FaIcon(FontAwesomeIcons.userTie, size: 12, color: appPrimary),
                          const SizedBox(width: 6),
                          Text(
                            instructor,
                            style: const TextStyle(color: appMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const FaIcon(FontAwesomeIcons.calendar, size: 12, color: appMuted),
                const SizedBox(width: 8),
                Text(dateRange, style: const TextStyle(color: appMuted, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: tags
                      .map((t) => Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: appCard,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                t.label,
                                style: TextStyle(
                                  color: t.color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                Text(
                  price,
                  style: const TextStyle(
                    color: appText,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: appCard,
        border: Border(top: BorderSide(color: appBorder)),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navItem(FontAwesomeIcons.house, 'Domů', false, () => context.go('/events')),
          _navItem(FontAwesomeIcons.magnifyingGlass, 'Hledat', false, null),
          _navFab(),
          _navItem(FontAwesomeIcons.bookOpen, 'Kurzy', true, null),
          _navItem(FontAwesomeIcons.user, 'Profil', false, () => context.go('/profile')),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive, VoidCallback? onTap) {
    final color = isActive ? appPrimary : appMuted;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 22, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _navFab() {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: appPrimary,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: appBg, width: 4),
          boxShadow: [
            BoxShadow(
              color: appPrimary.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: -5,
            ),
          ],
        ),
        child: const Center(
          child: FaIcon(FontAwesomeIcons.graduationCap, size: 20, color: Colors.white),
        ),
      ),
    );
  }
}

class _TagData {
  final String label;
  final Color color;
  const _TagData(this.label, this.color);
}
