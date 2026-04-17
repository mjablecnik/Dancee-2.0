import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/colors.dart';

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  int _selectedStyleIndex = 0;
  final List<String> _styles = ['Vše', 'Salsa', 'Bachata', 'Kizomba', 'Zouk'];

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
                  _buildDanceStyles(),
                  const SizedBox(height: 32),
                  _buildFeaturedEvents(),
                  const SizedBox(height: 32),
                  _buildUpcomingEvents(),
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
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: appBg.withValues(alpha: 0.9),
        border: const Border(bottom: BorderSide(color: appBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lokalita',
                    style: TextStyle(
                      color: appMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => context.push('/events/filter-location'),
                    child: Row(
                      children: [
                        const FaIcon(FontAwesomeIcons.locationDot, color: appPrimary, size: 16),
                        const SizedBox(width: 6),
                        const Text(
                          'Praha, CZ',
                          style: TextStyle(
                            color: appText,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const FaIcon(FontAwesomeIcons.chevronDown, color: appMuted, size: 12),
                      ],
                    ),
                  ),
                ],
              ),
              Stack(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: appSurface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: FaIcon(FontAwesomeIcons.bell, size: 18, color: appText),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: appSurface, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _quickFilterPill(FontAwesomeIcons.calendarDay, 'Dnes'),
                const SizedBox(width: 8),
                _quickFilterPill(FontAwesomeIcons.calendarWeek, 'Tento týden'),
                const SizedBox(width: 8),
                _quickFilterPill(null, 'Tento měsíc'),
                const SizedBox(width: 8),
                _quickFilterPill(null, 'Tento víkend'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickFilterPill(IconData? icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: appSurface,
        border: Border.all(color: appBorder),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            FaIcon(icon, size: 12, color: appText),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: const TextStyle(
              color: appText,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDanceStyles() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Taneční styly',
                style: TextStyle(
                  color: appText,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/events/filter-dance'),
                child: const Text(
                  'Zobrazit vše',
                  style: TextStyle(
                    color: appMuted,
                    fontSize: 14,
                  ),
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
            children: List.generate(_styles.length, (index) {
              final isActive = _selectedStyleIndex == index;
              return Padding(
                padding: EdgeInsets.only(right: index < _styles.length - 1 ? 12 : 0),
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

  Widget _buildFeaturedEvents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Doporučené akce',
            style: TextStyle(color: appText, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _featuredCard(
                imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/1887dced68-753b152bd32ad7f3eb9b.png',
                title: 'Prague Latin Festival 2025 - Mega Edition',
                date: '12. Říj - 14. Říj 2025',
                location: 'Kongresové centrum, Praha',
                price: 'Od 350 Kč',
                isFree: false,
                isFavorited: false,
                tags: [
                  _TagData('Salsa', appPrimary),
                  _TagData('Bachata', appAccent),
                ],
              ),
              const SizedBox(width: 16),
              _featuredCard(
                imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/35e8621ce9-d463887a55ba17b5c416.png',
                title: 'Kizomba Open Air Social',
                date: 'Dnes, 18:00 - 23:00',
                location: 'Střelecký ostrov, Praha',
                price: 'Zdarma',
                isFree: true,
                isFavorited: true,
                tags: [
                  _TagData('Kizomba', const Color(0xFFC084FC)),
                  _TagData('Semba', const Color(0xFF60A5FA)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _featuredCard({
    required String imageUrl,
    required String title,
    required String date,
    required String location,
    required String price,
    required bool isFree,
    required bool isFavorited,
    required List<_TagData> tags,
  }) {
    return GestureDetector(
      onTap: () => context.push('/events/detail'),
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
                    height: 160,
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
                  right: 12,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: FaIcon(
                        isFavorited ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                        size: 14,
                        color: isFavorited ? Colors.red : Colors.white,
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
                      color: isFree ? appSuccess.withValues(alpha: 0.9) : appPrimary.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      price,
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
                      const FaIcon(FontAwesomeIcons.calendar, size: 14, color: appMuted),
                      const SizedBox(width: 8),
                      Text(date, style: const TextStyle(color: appMuted, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.locationDot, size: 14, color: appPrimary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(color: appMuted, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: tags
                        .map((t) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: appSurface,
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
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingEvents() {
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
                'Nadcházející akce',
                style: TextStyle(color: appText, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: appSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const FaIcon(FontAwesomeIcons.arrowUpWideShort, size: 14, color: appText),
                    const SizedBox(width: 8),
                    const Text('Datum', style: TextStyle(color: appText, fontSize: 14)),
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
              _upcomingEventItem(
                imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/a7414ef4de-19550fae1cabebe15c09.png',
                title: 'Bachata Sensual Workshop s mezinárodními lektory',
                location: 'Dance Studio 1, Brno',
                date: '20. Říj, 14:00',
                style: 'Bachata',
                styleColor: appAccent,
                isFavorited: false,
              ),
              const SizedBox(height: 16),
              _upcomingEventItem(
                imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/9d038750ea-18e3a1b3f78567f6cc57.png',
                title: 'Havana Night - Živá kapela a animace',
                location: 'Klub Tres, Ostrava',
                date: '22. Říj, 20:00',
                style: 'Salsa',
                styleColor: appPrimary,
                isFavorited: true,
              ),
              const SizedBox(height: 16),
              _upcomingEventItem(
                imageUrl: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/858406cadf-a18221d3c2f7fc2a6f2a.png',
                title: 'Zouk Weekend Marathon 2025',
                location: 'Hotel Pyramida, Praha',
                date: '1. Lis - 3. Lis',
                style: 'Zouk',
                styleColor: const Color(0xFF34D399),
                isFavorited: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _upcomingEventItem({
    required String imageUrl,
    required String title,
    required String location,
    required String date,
    required String style,
    required Color styleColor,
    required bool isFavorited,
  }) {
    return GestureDetector(
      onTap: () => context.push('/events/detail'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: appSurface,
          border: Border.all(color: appBorder),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 32, top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            const FaIcon(FontAwesomeIcons.locationDot, size: 12, color: appPrimary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location,
                                style: const TextStyle(color: appMuted, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: appCard,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                date,
                                style: const TextStyle(
                                  color: appText,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              style.toUpperCase(),
                              style: TextStyle(
                                color: styleColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: FaIcon(
                    isFavorited ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                    size: 14,
                    color: isFavorited ? Colors.red : appMuted,
                  ),
                ),
              ),
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
          _navItem(FontAwesomeIcons.house, 'Domů', false, null),
          _navItem(FontAwesomeIcons.magnifyingGlass, 'Hledat', true, null),
          _navFab(),
          _navItem(FontAwesomeIcons.heart, 'Uložené', false, null),
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
          child: FaIcon(FontAwesomeIcons.plus, size: 20, color: Colors.white),
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
