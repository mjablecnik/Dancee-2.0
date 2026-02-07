import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/event_list/event_list_cubit.dart';
import '../cubits/event_list/event_list_state.dart';
import '../di/service_locator.dart';
import 'package:dancee_shared/dancee_shared.dart';
import '../i18n/translations.g.dart';
import '../widgets/event_card.dart';

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
      
      // Trigger search when text changes
      if (_searchController.text.isEmpty) {
        getIt<EventListCubit>().loadEvents();
      } else {
        getIt<EventListCubit>().searchEvents(_searchController.text);
      }
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
        child: BlocBuilder<EventListCubit, EventListState>(
          bloc: getIt<EventListCubit>(),
          builder: (context, state) {
            if (state is EventListLoading) {
              return _buildLoadingState();
            }
            
            if (state is EventListError) {
              return _buildErrorState(state.message);
            }
            
            if (state is EventListLoaded) {
              return _buildLoadedState(state);
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
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => getIt<EventListCubit>().loadEvents(),
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

  Widget _buildLoadedState(EventListLoaded state) {
    return CustomScrollView(
      slivers: [
        _buildAnimatedHeader(),
        SliverToBoxAdapter(
          child: _buildSearchAndFilters(),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
          sliver: _buildEventsSliverList(state),
        ),
      ],
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
                            t.dancee,
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
          hintText: t.searchEvents,
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
          _buildFilterChip(t.filters, hasNotification: true, notificationCount: 2),
          const SizedBox(width: 8),
          _buildFilterChip(t.today, icon: Icons.calendar_today),
          const SizedBox(width: 8),
          _buildFilterChip(t.prague, icon: Icons.location_on),
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
  Widget _buildEventsSliverList(EventListLoaded state) {
    return SliverList(
      delegate: SliverChildListDelegate([
        if (state.todayEvents.isNotEmpty) ...[
          _buildTodaySection(state.todayEvents),
          const SizedBox(height: 24),
        ],
        if (state.tomorrowEvents.isNotEmpty) ...[
          _buildTomorrowSection(state.tomorrowEvents),
          const SizedBox(height: 24),
        ],
        if (state.upcomingEvents.isNotEmpty) ...[
          _buildUpcomingSection(state.upcomingEvents),
        ],
      ]),
    );
  }

  Widget _buildTodaySection(List<Event> events) {
    return Column(
      children: [
        _buildSectionHeader(
          t.today,
          t.tuesdayDate(date: '4.2.2025'),
          t.eventsCount(count: events.length),
          Icons.calendar_today,
          const Color(0xFF6366F1),
        ),
        const SizedBox(height: 16),
        Column(
          children: events.map((event) => EventCard(
            event: event,
            onTap: () {
              // TODO: Navigate to event detail
            },
            onFavoriteToggle: () {
              getIt<EventListCubit>().toggleFavorite(event.id);
            },
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildTomorrowSection(List<Event> events) {
    return Column(
      children: [
        _buildSectionHeader(
          t.tomorrow,
          t.wednesdayDate(date: '5.2.2025'),
          t.eventsCount(count: events.length),
          Icons.calendar_month,
          const Color(0xFF8B5CF6),
        ),
        const SizedBox(height: 16),
        Column(
          children: events.map((event) => EventCard(
            event: event,
            onTap: () {
              // TODO: Navigate to event detail
            },
            onFavoriteToggle: () {
              getIt<EventListCubit>().toggleFavorite(event.id);
            },
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildUpcomingSection(List<Event> events) {
    return Column(
      children: [
        _buildSectionHeader(
          t.thisWeek,
          '',
          t.eventsCount(count: events.length),
          Icons.calendar_view_week,
          const Color(0xFFEC4899),
        ),
        const SizedBox(height: 16),
        Column(
          children: events.map((event) => EventCard(
            event: event,
            onTap: () {
              // TODO: Navigate to event detail
            },
            onFavoriteToggle: () {
              getIt<EventListCubit>().toggleFavorite(event.id);
            },
          )).toList(),
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
}