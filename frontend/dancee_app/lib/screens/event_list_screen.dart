import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _showClearButton = _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAnimatedHeader(),
            SliverToBoxAdapter(
              child: _buildSearchAndFilters(),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
              sliver: _buildEventsSliverList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return SliverAppBar(
      expandedHeight: 100.0, // Large header height
      collapsedHeight: 70, // Small header height when collapsed
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF6366F1),
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Calculate animation progress (0.0 = expanded, 1.0 = collapsed)
          final double appBarHeight = constraints.biggest.height;
          final double expandedHeight = 120.0;
          final double collapsedHeight = 60.0;
          
          // Normalize the animation progress
          final double animationProgress = ((expandedHeight - appBarHeight) / (expandedHeight - collapsedHeight)).clamp(0.0, 1.0);
          
          // Interpolate sizes based on animation progress - matching design exactly
          final double iconSize = 48.0 - (16.0 * animationProgress); // 40px -> 32px (w-10 h-10 -> smaller)
          final double iconInnerSize = 24.0 - (8.0 * animationProgress); // 18px -> 16px (text-lg equivalent)
          final double borderRadius = 12.0 - (4.0 * animationProgress); // 12px -> 8px (rounded-xl -> rounded-lg)
          final double titleFontSize = 32.0 - (16.0 * animationProgress); // 24px -> 16px (larger initial size)
          final double horizontalPadding = 20.0;
          
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  //vertical: verticalPadding,
                ),
                child: Row(
                  children: [
                    Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(borderRadius), // Exact border radius from design
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8.0 - (4.0 * animationProgress), // shadow-lg equivalent
                            offset: Offset(0, 2.0 - (1.0 * animationProgress)),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.music_note, // Closest Flutter equivalent to fa-music
                        color: const Color(0xFF6366F1), // text-primary color
                        size: iconInnerSize,
                      ),
                    ),
                    SizedBox(width: 12.0 * (1.0 - animationProgress * 0.5)), // gap-3 equivalent
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Dancee',
                            style: GoogleFonts.inter(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold, // font-bold
                              color: Colors.white, // text-white
                            ),
                          ),
                          // Hide subtitle when fully collapsed to save space
                          //if (animationProgress < 0.8) ...[
                          //  SizedBox(height: 2.0 * (1.0 - animationProgress)),
                          //  Text(
                          //    'Dance Events',
                          //    style: GoogleFonts.inter(
                          //      fontSize: subtitleFontSize,
                          //      color: Colors.white.withValues(alpha: 0.8), // text-white/80
                          //    ),
                          //  ),
                          //],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilters() {
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
      child: Column(
        children: [
          _buildSearchSection(),
          const SizedBox(height: 16),
          _buildFilterSection(),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.inter(
          color: const Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          hintText: 'Search events...',
          hintStyle: GoogleFonts.inter(
            color: Colors.grey[400],
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[400],
          ),
          suffixIcon: _showClearButton
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                  },
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey[400],
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('Filters', hasNotification: true, notificationCount: 2),
          const SizedBox(width: 8),
          _buildFilterChip('Today', icon: Icons.calendar_today),
          const SizedBox(width: 8),
          _buildFilterChip('Prague', icon: Icons.location_on),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {IconData? icon, bool hasNotification = false, int notificationCount = 0}) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          if (hasNotification) ...[
            const SizedBox(width: 8),
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  notificationCount.toString(),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  Widget _buildEventsSliverList() {
    return SliverList(
      delegate: SliverChildListDelegate([
        _buildTodaySection(),
        const SizedBox(height: 24),
        _buildTomorrowSection(),
        const SizedBox(height: 24),
        _buildUpcomingSection(),
      ]),
    );
  }

  Widget _buildTodaySection() {
    return Column(
      children: [
        _buildSectionHeader(
          'Today',
          '(Tuesday 4.2.2025)',
          '3 events',
          Icons.calendar_today,
          const Color(0xFF6366F1),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            _buildEventCard(
              'Salsa Social Night',
              'Lucerna Music Bar',
              '20:00 - 02:00',
              '6 hours',
              ['Salsa', 'Bachata', 'Kizomba'],
              false,
            ),
            _buildEventCard(
              'Bachata Tuesdays',
              'Dance Arena Prague',
              '19:30 - 23:30',
              '4 hours',
              ['Bachata', 'Sensual'],
              true,
            ),
            _buildEventCard(
              'Zouk Workshop & Party',
              'Studio Tance',
              '18:00 - 22:00',
              '4 hours',
              ['Zouk', 'Brazilian Zouk'],
              false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTomorrowSection() {
    return Column(
      children: [
        _buildSectionHeader(
          'Tomorrow',
          '(Wednesday 5.2.2025)',
          '5 events',
          Icons.calendar_month,
          const Color(0xFF8B5CF6),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            _buildEventCard(
              'Kizomba Wednesday',
              'Club Lavka',
              '20:00 - 01:00',
              '5 hours',
              ['Kizomba', 'Urban Kiz', 'Tarraxo'],
              false,
            ),
            _buildEventCard(
              'Tango Practica',
              'Café Milonga',
              '19:00 - 22:00',
              '3 hours',
              ['Tango', 'Argentine Tango'],
              true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUpcomingSection() {
    return Column(
      children: [
        _buildSectionHeader(
          'This week',
          '',
          '16 events',
          Icons.calendar_view_week,
          const Color(0xFFEC4899),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            _buildEventCard(
              'Latin Mix Party',
              'Cross Club',
              '21:00 - 03:00',
              '6 hours',
              ['Salsa', 'Bachata', 'Merengue'],
              false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, String count, IconData icon, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
        Text(
          count,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard(
    String title,
    String venue,
    String time,
    String duration,
    List<String> tags,
    bool isFavorite,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: const Color(0xFF6366F1),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            venue,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isFavorite ? Colors.red[50] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: isFavorite ? Colors.red : Colors.grey[400],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: const Color(0xFF6366F1),
              ),
              const SizedBox(width: 8),
              Text(
                time,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                duration,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) => _buildTag(tag)).toList(),
          ),

        ],
      ),
    );
  }

  Widget _buildTag(String tag) {
    final colors = _getTagColors(tag);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors['gradient']!,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors['border']!),
      ),
      child: Text(
        tag,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: colors['text']!,
        ),
      ),
    );
  }

  Map<String, dynamic> _getTagColors(String tag) {
    switch (tag.toLowerCase()) {
      case 'salsa':
        return {
          'gradient': [const Color(0xFFFEF2F2), const Color(0xFFFFF7ED)],
          'border': const Color(0xFFFECACA),
          'text': const Color(0xFFB91C1C),
        };
      case 'bachata':
        return {
          'gradient': [const Color(0xFFFDF2F8), const Color(0xFFFFF1F2)],
          'border': const Color(0xFFFBCAD3),
          'text': const Color(0xFFBE185D),
        };
      case 'kizomba':
        return {
          'gradient': [const Color(0xFFF3E8FF), const Color(0xFFEDE9FE)],
          'border': const Color(0xFFD8B4FE),
          'text': const Color(0xFF7C3AED),
        };
      case 'zouk':
      case 'brazilian zouk':
        return {
          'gradient': [const Color(0xFFF0FDFA), const Color(0xFFECFDF5)],
          'border': const Color(0xFFA7F3D0),
          'text': const Color(0xFF047857),
        };
      case 'tango':
      case 'argentine tango':
        return {
          'gradient': [const Color(0xFFF8FAFC), const Color(0xFFF1F5F9)],
          'border': const Color(0xFFCBD5E1),
          'text': const Color(0xFF475569),
        };
      case 'sensual':
        return {
          'gradient': [const Color(0xFFFDF2F8), const Color(0xFFFFF1F2)],
          'border': const Color(0xFFFBCAD3),
          'text': const Color(0xFFBE185D),
        };
      case 'urban kiz':
        return {
          'gradient': [const Color(0xFFF3E8FF), const Color(0xFFEDE9FE)],
          'border': const Color(0xFFD8B4FE),
          'text': const Color(0xFF7C3AED),
        };
      case 'tarraxo':
        return {
          'gradient': [const Color(0xFFF3E8FF), const Color(0xFFEDE9FE)],
          'border': const Color(0xFFD8B4FE),
          'text': const Color(0xFF7C3AED),
        };
      case 'merengue':
        return {
          'gradient': [const Color(0xFFFEF2F2), const Color(0xFFFFF7ED)],
          'border': const Color(0xFFFECACA),
          'text': const Color(0xFFB91C1C),
        };
      default:
        return {
          'gradient': [const Color(0xFFF9FAFB), const Color(0xFFF3F4F6)],
          'border': const Color(0xFFD1D5DB),
          'text': const Color(0xFF6B7280),
        };
    }
  }
}