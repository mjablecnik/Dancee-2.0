import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/favorites/favorites_cubit.dart';
import '../cubits/favorites/favorites_state.dart';
import '../di/service_locator.dart';
import '../models/event.dart';
import '../i18n/translations.g.dart';

class FavoritesScreen extends StatefulWidget {
  final ValueNotifier<int>? reloadTrigger;
  
  const FavoritesScreen({super.key, this.reloadTrigger});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // Load favorites when screen is first created
    getIt<FavoritesCubit>().loadFavorites();
    
    // Listen to reload trigger from parent
    widget.reloadTrigger?.addListener(_onReloadTriggered);
  }

  @override
  void dispose() {
    widget.reloadTrigger?.removeListener(_onReloadTriggered);
    super.dispose();
  }

  void _onReloadTriggered() {
    // Filter out unfavorited events when returning to this screen
    getIt<FavoritesCubit>().filterUnfavoritedEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: BlocBuilder<FavoritesCubit, FavoritesState>(
          bloc: getIt<FavoritesCubit>(),
          builder: (context, state) {
            if (state is FavoritesLoading) {
              return _buildLoadingState();
            }
            
            if (state is FavoritesEmpty) {
              return _buildEmptyState();
            }
            
            if (state is FavoritesError) {
              return _buildErrorState(state.message);
            }
            
            if (state is FavoritesLoaded) {
              return _buildFavoritesList(state);
            }
            
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            t.errorLoadingFavorites,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => getIt<FavoritesCubit>().loadFavorites(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              t.retry,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(FavoritesLoaded state) {
    final upcomingEvents = state.upcomingEvents;
    final pastEvents = state.pastEvents;
    final totalEvents = upcomingEvents.length + pastEvents.length;
    
    return CustomScrollView(
      slivers: [
        _buildHeader(totalEvents),
        _buildFilterSection(),
        if (upcomingEvents.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: _buildSectionHeader(t.upcomingEvents),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildEventCard(context, upcomingEvents[index]);
                },
                childCount: upcomingEvents.length,
              ),
            ),
          ),
        ],
        if (pastEvents.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: _buildSectionHeader(t.pastEvents),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildEventCard(context, pastEvents[index]);
                },
                childCount: pastEvents.length,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHeader(int totalEvents) {
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
                  t.favoriteEvents,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.savedEvents(count: totalEvents),
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
    return SliverToBoxAdapter(
      child: Container(
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
              _buildFilterChip(t.all, true),
              const SizedBox(width: 8),
              _buildFilterChip(t.today, false),
              const SizedBox(width: 8),
              _buildFilterChip(t.thisWeek, false),
              const SizedBox(width: 8),
              _buildFilterChip(t.thisMonth, false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
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

  Widget _buildEventCard(BuildContext context, Event event) {
    // Format date and time
    final dateFormat = _formatDate(event.startTime);
    final timeFormat = _formatTime(event.startTime, event.endTime);
    
    // Get gradient colors based on first dance style
    final gradientColors = _getGradientColors(event.dances.isNotEmpty ? event.dances.first : '');
    
    final cardContent = Container(
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
            // TODO: Navigate to event detail
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
                            colors: gradientColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.music_note,
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
                                Expanded(
                                  child: Text(
                                    event.venue.name,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: event.isPast ? Colors.grey[500] : Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
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
                                  dateFormat,
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
                                  timeFormat,
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
                                color: event.isPast 
                                    ? Colors.red[50] 
                                    : (event.isFavorite ? Colors.red[50] : Colors.grey[200]),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () {
                                    if (event.isPast) {
                                      // For past events, remove immediately
                                      getIt<FavoritesCubit>().removePastEvent(event.id);
                                    } else {
                                      // For upcoming events, toggle favorite
                                      getIt<FavoritesCubit>().toggleFavorite(event.id);
                                    }
                                  },
                                  child: Icon(
                                    event.isPast 
                                        ? Icons.delete 
                                        : (event.isFavorite ? Icons.favorite : Icons.favorite_border),
                                    color: event.isPast 
                                        ? Colors.red[600] 
                                        : (event.isFavorite ? Colors.red[600] : Colors.grey[400]),
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
                          children: event.dances.map((dance) => _buildTag(dance, event.isPast)).toList(),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            t.detail,
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

    // Wrap past events in Dismissible for swipe-to-delete animation
    if (event.isPast) {
      return Dismissible(
        key: Key(event.id),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          getIt<FavoritesCubit>().removePastEvent(event.id);
        },
        background: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.red[400],
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: Icon(
            Icons.delete,
            color: Colors.white,
            size: 32,
          ),
        ),
        child: cardContent,
      );
    }
    
    return cardContent;
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (eventDate == today) {
      return t.today;
    } else if (eventDate == today.add(const Duration(days: 1))) {
      return t.tomorrow;
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[dateTime.month - 1]} ${dateTime.day}';
    }
  }

  String _formatTime(DateTime start, DateTime end) {
    final startHour = start.hour.toString().padLeft(2, '0');
    final startMinute = start.minute.toString().padLeft(2, '0');
    final endHour = end.hour.toString().padLeft(2, '0');
    final endMinute = end.minute.toString().padLeft(2, '0');
    return '$startHour:$startMinute - $endHour:$endMinute';
  }

  List<Color> _getGradientColors(String dance) {
    switch (dance.toLowerCase()) {
      case 'salsa':
        return [const Color(0xFFEF4444), const Color(0xFFDC2626)];
      case 'bachata':
        return [const Color(0xFFEC4899), const Color(0xFFDB2777)];
      case 'kizomba':
        return [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)];
      case 'zouk':
      case 'brazilian zouk':
        return [const Color(0xFF14B8A6), const Color(0xFF0D9488)];
      case 'tango':
        return [const Color(0xFF6366F1), const Color(0xFF4F46E5)];
      default:
        return [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
    }
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
              t.noFavoriteEvents,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              t.noFavoriteEventsDescription,
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
                        t.browseEvents,
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


}