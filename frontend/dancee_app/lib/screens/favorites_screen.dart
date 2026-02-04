import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoriteEvent {
  final String id;
  final String title;
  final String venue;
  final String date;
  final String time;
  final List<String> tags;
  final IconData iconData;
  final List<Color> gradientColors;
  final String? badge;
  final bool isPast;

  FavoriteEvent({
    required this.id,
    required this.title,
    required this.venue,
    required this.date,
    required this.time,
    required this.tags,
    required this.iconData,
    required this.gradientColors,
    this.badge,
    this.isPast = false,
  });
}

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with TickerProviderStateMixin {
  String selectedFilter = 'All';

  List<FavoriteEvent> favoriteEvents = [
    FavoriteEvent(
      id: '1',
      title: 'Salsa & Bachata Night Prague',
      venue: 'Dance Club Central',
      date: 'Fri 4. February',
      time: '20:00',
      tags: ['Salsa', 'Bachata', 'Kizomba'],
      iconData: Icons.local_fire_department,
      gradientColors: [const Color(0xFFEF4444), const Color(0xFFF97316)],
      badge: 'TODAY',
    ),
    FavoriteEvent(
      id: '2',
      title: 'Bachata Sensual Workshop',
      venue: 'Studio Rytmus',
      date: 'Sun 6. February',
      time: '18:00',
      tags: ['Bachata', 'Sensual'],
      iconData: Icons.favorite,
      gradientColors: [const Color(0xFFEC4899), const Color(0xFFF43F5E)],
      badge: 'IN 2 DAYS',
    ),
    FavoriteEvent(
      id: '3',
      title: 'Kizomba Fusion Party',
      venue: 'Karlín Hall',
      date: 'Fri 11. February',
      time: '21:00',
      tags: ['Kizomba', 'Urban Kiz', 'Tarraxo'],
      iconData: Icons.nightlight_round,
      gradientColors: [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
    ),
    FavoriteEvent(
      id: '4',
      title: 'Zouk Social Dance',
      venue: 'Dance Factory',
      date: 'Sat 12. February',
      time: '19:30',
      tags: ['Zouk', 'Brazilian Zouk'],
      iconData: Icons.water_drop,
      gradientColors: [const Color(0xFF14B8A6), const Color(0xFF06B6D4)],
    ),
    FavoriteEvent(
      id: '5',
      title: 'Salsa On2 Masterclass',
      venue: 'Dance Club Central',
      date: 'Sun 13. February',
      time: '16:00',
      tags: ['Salsa', 'On2'],
      iconData: Icons.wb_sunny,
      gradientColors: [const Color(0xFFF59E0B), const Color(0xFFEAB308)],
    ),
    FavoriteEvent(
      id: '6',
      title: 'Samba de Gafieira Evening',
      venue: 'Rio Dance Studio',
      date: 'Thu 17. February',
      time: '20:00',
      tags: ['Samba', 'Gafieira'],
      iconData: Icons.eco,
      gradientColors: [const Color(0xFF10B981), const Color(0xFF059669)],
    ),
    FavoriteEvent(
      id: '7',
      title: 'Latin Night Mix',
      venue: 'Lucerna Music Bar',
      date: 'Fri 18. February',
      time: '22:00',
      tags: ['Salsa', 'Bachata', 'Merengue', 'Reggaeton'],
      iconData: Icons.celebration,
      gradientColors: [const Color(0xFF3B82F6), const Color(0xFF6366F1)],
    ),
    FavoriteEvent(
      id: '8',
      title: 'Bachata Romántica Night',
      venue: 'Dance Club Central',
      date: 'Sat 19. February',
      time: '20:30',
      tags: ['Bachata', 'Romántica'],
      iconData: Icons.monitor_heart,
      gradientColors: [const Color(0xFFF43F5E), const Color(0xFFEC4899)],
    ),
    // Past events
    FavoriteEvent(
      id: '9',
      title: 'Salsa Cubana Workshop',
      venue: 'Studio Rytmus',
      date: 'Sat 28. January',
      time: '17:00',
      tags: ['Salsa', 'Cubana'],
      iconData: Icons.event_busy,
      gradientColors: [const Color(0xFF9CA3AF), const Color(0xFF6B7280)],
      badge: 'FINISHED',
      isPast: true,
    ),
    FavoriteEvent(
      id: '10',
      title: 'Kizomba Ladies Styling',
      venue: 'Karlín Hall',
      date: 'Sun 22. January',
      time: '15:00',
      tags: ['Kizomba', 'Ladies'],
      iconData: Icons.event_busy,
      gradientColors: [const Color(0xFF9CA3AF), const Color(0xFF6B7280)],
      badge: 'FINISHED',
      isPast: true,
    ),
  ];
  List<FavoriteEvent> get upcomingEvents => favoriteEvents.where((event) => !event.isPast).toList();
  List<FavoriteEvent> get pastEvents => favoriteEvents.where((event) => event.isPast).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: favoriteEvents.isEmpty ? _buildEmptyState() : _buildFavoritesList(),
      ),
    );
  }

  Widget _buildFavoritesList() {
    return CustomScrollView(
      slivers: [
        _buildHeader(),
        SliverToBoxAdapter(
          child: _buildFilterSection(),
        ),
        if (upcomingEvents.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: _buildSectionHeader('Upcoming Events'),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildEventCard(upcomingEvents[index]);
                },
                childCount: upcomingEvents.length,
              ),
            ),
          ),
        ],
        if (pastEvents.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: _buildSectionHeader('Past Events'),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildEventCard(pastEvents[index]);
                },
                childCount: pastEvents.length,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 140.0,
      collapsedHeight: 80,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF6366F1),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Favorite Events',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${favoriteEvents.length} saved events',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', selectedFilter == 'All'),
            const SizedBox(width: 8),
            _buildFilterChip('Today', selectedFilter == 'Today'),
            const SizedBox(width: 8),
            _buildFilterChip('This week', selectedFilter == 'This week'),
            const SizedBox(width: 8),
            _buildFilterChip('This month', selectedFilter == 'This month'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check, color: Color(0xFF6366F1), size: 16),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF6366F1) : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF0F172A),
        ),
      ),
    );
  }

  Widget _buildEventCard(FavoriteEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: event.isPast ? Colors.grey[300]! : Colors.grey[200]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: event.isPast ? null : () {
            // Navigate to event detail
            print('Navigate to event detail: ${event.title}');
          },
          child: Opacity(
            opacity: event.isPast ? 0.6 : 1.0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: event.gradientColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          event.iconData,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: event.isPast ? Colors.grey[600] : const Color(0xFF0F172A),
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 12,
                                  color: event.isPast ? Colors.grey[500] : Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  event.venue,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: event.isPast ? Colors.grey[500] : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 12,
                                  color: event.isPast ? Colors.grey[500] : const Color(0xFF6366F1),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  event.date,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: event.isPast ? Colors.grey[500] : Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.access_time,
                                  size: 12,
                                  color: event.isPast ? Colors.grey[500] : const Color(0xFF8B5CF6),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  event.time,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: event.isPast ? Colors.grey[500] : Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (event.badge != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getBadgeColor(event.badge!),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                event.badge!,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () => _showRemoveConfirmation(event),
                                  child: Icon(
                                    event.isPast ? Icons.delete : Icons.heart_broken,
                                    color: Colors.red[600],
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: event.tags.map((tag) => _buildTag(tag, event.isPast)).toList(),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            "Detail",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: event.isPast ? Colors.grey[500] : Colors.grey[600],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: event.isPast ? Colors.grey[400] : Colors.grey[500],
                            size: 24,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String tag, bool isPast) {
    final colors = _getTagColors(tag);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPast ? Colors.grey[200] : colors['background'],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        tag,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isPast ? Colors.grey[600] : colors['text'],
        ),
      ),
    );
  }

  Map<String, Color> _getTagColors(String tag) {
    switch (tag.toLowerCase()) {
      case 'salsa':
        return {'background': Colors.red[100]!, 'text': Colors.red[700]!};
      case 'bachata':
        return {'background': Colors.pink[100]!, 'text': Colors.pink[700]!};
      case 'kizomba':
        return {'background': Colors.purple[100]!, 'text': Colors.purple[700]!};
      case 'zouk':
      case 'brazilian zouk':
        return {'background': Colors.teal[100]!, 'text': Colors.teal[700]!};
      case 'sensual':
        return {'background': Colors.pink[100]!, 'text': Colors.pink[700]!};
      case 'urban kiz':
        return {'background': Colors.deepPurple[100]!, 'text': Colors.deepPurple[700]!};
      case 'tarraxo':
        return {'background': Colors.indigo[100]!, 'text': Colors.indigo[700]!};
      case 'on2':
        return {'background': Colors.orange[100]!, 'text': Colors.orange[700]!};
      case 'gafieira':
        return {'background': Colors.green[100]!, 'text': Colors.green[700]!};
      case 'merengue':
        return {'background': Colors.amber[100]!, 'text': Colors.amber[700]!};
      case 'reggaeton':
        return {'background': Colors.green[100]!, 'text': Colors.green[700]!};
      case 'romántica':
        return {'background': Colors.pink[100]!, 'text': Colors.pink[700]!};
      case 'cubana':
        return {'background': Colors.red[100]!, 'text': Colors.red[700]!};
      case 'ladies':
        return {'background': Colors.pink[100]!, 'text': Colors.pink[700]!};
      default:
        return {'background': Colors.grey[100]!, 'text': Colors.grey[700]!};
    }
  }

  Color _getBadgeColor(String badge) {
    switch (badge.toLowerCase()) {
      case 'today':
        return Colors.green[500]!;
      case 'in 2 days':
        return Colors.blue[500]!;
      case 'finished':
        return Colors.grey[400]!;
      default:
        return Colors.grey[400]!;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey[100]!, Colors.grey[200]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.heart_broken,
                color: Colors.grey[400],
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Favorite Events',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You haven\'t saved any favorite events yet. Start exploring dance events and save the ones that interest you.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    // Navigate to events list
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.explore, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Browse Events',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveConfirmation(FavoriteEvent event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.red[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.heart_broken,
                color: Colors.red[600],
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Remove from Favorites?',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This event will be removed from your favorite items.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          favoriteEvents.removeWhere((e) => e.id == event.id);
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '✓ Removed from favorites',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            backgroundColor: Colors.red[600],
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.delete, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Yes, Remove',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey[200]!, Colors.grey[300]!],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.pop(context),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}