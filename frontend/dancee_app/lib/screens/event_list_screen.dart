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
        child: Container(
          constraints: const BoxConstraints(maxWidth: 375),
          child: Column(
            children: [
              _buildHeader(),
              _buildActiveFilters(),
              _buildStatsBar(),
              Expanded(
                child: _buildEventsList(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
      child: Column(
        children: [
          _buildHeaderTop(),
          const SizedBox(height: 24),
          _buildSearchSection(),
          const SizedBox(height: 16),
          _buildFilterSection(),
        ],
      ),
    );
  }

  Widget _buildHeaderTop() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.music_note,
                color: Color(0xFF6366F1),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dancee',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Taneční akce',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              const Center(
                child: Icon(
                  Icons.notifications,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '3',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
          hintText: 'Hledat akce...',
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
          _buildFilterChip('Filtry', hasNotification: true, notificationCount: 2),
          const SizedBox(width: 8),
          _buildFilterChip('Dnes', icon: Icons.calendar_today),
          const SizedBox(width: 8),
          _buildFilterChip('Praha', icon: Icons.location_on),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {IconData? icon, bool hasNotification = false, int notificationCount = 0}) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
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

  Widget _buildActiveFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFFDEF7FF),
        border: Border(
          bottom: BorderSide(color: Color(0xFFBFE7FF)),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Aktivní filtry:',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Zrušit vše',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6366F1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildActiveFilterChip('Salsa'),
              const SizedBox(width: 8),
              _buildActiveFilterChip('Praha'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBFE7FF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {},
            child: Icon(
              Icons.close,
              size: 12,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF0F4FF), Color(0xFFF3E8FF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E7FF)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.event_available,
                color: Color(0xFF6366F1),
                size: 16,
              ),
              const SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                  children: const [
                    TextSpan(text: 'Nalezeno '),
                    TextSpan(
                      text: '24',
                      style: TextStyle(color: Color(0xFF6366F1)),
                    ),
                    TextSpan(text: ' akcí'),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(
                Icons.sort,
                color: Colors.grey,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Seřadit',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildEventsList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
      child: Column(
        children: [
          _buildTodaySection(),
          const SizedBox(height: 24),
          _buildTomorrowSection(),
          const SizedBox(height: 24),
          _buildUpcomingSection(),
        ],
      ),
    );
  }

  Widget _buildTodaySection() {
    return Column(
      children: [
        _buildSectionHeader(
          'Dnes',
          '(Úterý 4.2.2025)',
          '3 akce',
          Icons.calendar_today,
          const Color(0xFF6366F1),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            _buildEventCard(
              'Salsa Social Night',
              'Lucerna Music Bar',
              '20:00 - 02:00',
              '6 hodin',
              '150 Kč',
              '89 účastníků',
              ['Salsa', 'Bachata', 'Kizomba'],
              false,
            ),
            const SizedBox(height: 12),
            _buildEventCard(
              'Bachata Tuesdays',
              'Dance Arena Prague',
              '19:30 - 23:30',
              '4 hodiny',
              '100 Kč',
              '54 účastníků',
              ['Bachata', 'Sensual'],
              true,
            ),
            const SizedBox(height: 12),
            _buildEventCard(
              'Zouk Workshop & Party',
              'Studio Tance',
              '18:00 - 22:00',
              '4 hodiny',
              '200 Kč',
              '32 účastníků',
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
          'Zítra',
          '(Středa 5.2.2025)',
          '5 akcí',
          Icons.calendar_month,
          const Color(0xFF8B5CF6),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            _buildEventCard(
              'Kizomba Wednesday',
              'Club Lavka',
              '20:00 - 01:00',
              '5 hodin',
              '120 Kč',
              '67 účastníků',
              ['Kizomba', 'Urban Kiz', 'Tarraxo'],
              false,
            ),
            const SizedBox(height: 12),
            _buildEventCard(
              'Tango Practica',
              'Café Milonga',
              '19:00 - 22:00',
              '3 hodiny',
              '80 Kč',
              '28 účastníků',
              ['Tango', 'Argentinské Tango'],
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
          'Tento týden',
          '',
          '16 akcí',
          Icons.calendar_view_week,
          const Color(0xFFEC4899),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            _buildEventCard(
              'Latin Mix Party',
              'Cross Club',
              '21:00 - 03:00',
              '6 hodin',
              '150 Kč',
              '112 účastníků',
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
    String price,
    String participants,
    List<String> tags,
    bool isFavorite,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: const Color(0xFF6366F1),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          venue,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isFavorite ? Colors.red[50] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 16,
                  color: isFavorite ? Colors.red : Colors.grey[400],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: const Color(0xFF6366F1),
              ),
              const SizedBox(width: 6),
              Text(
                time,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                duration,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tags.map((tag) => _buildTag(tag)).toList(),
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: Colors.grey[100],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.confirmation_number,
                        size: 12,
                        color: Colors.green[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        price,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 12,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        participants,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String tag) {
    final colors = _getTagColors(tag);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          fontSize: 12,
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
      case 'argentinské tango':
        return {
          'gradient': [const Color(0xFFF8FAFC), const Color(0xFFF1F5F9)],
          'border': const Color(0xFFCBD5E1),
          'text': const Color(0xFF475569),
        };
      default:
        return {
          'gradient': [const Color(0xFFF9FAFB), const Color(0xFFF3F4F6)],
          'border': const Color(0xFFD1D5DB),
          'text': const Color(0xFF6B7280),
        };
    }
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 'Domů', true),
            _buildNavItem(Icons.search, 'Hledat', false),
            _buildNavItem(Icons.favorite, 'Oblíbené', false),
            _buildNavItem(Icons.person, 'Profil', false),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isActive ? const Color(0xFF6366F1) : Colors.grey[400],
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: isActive ? const Color(0xFF6366F1) : Colors.grey[400],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}