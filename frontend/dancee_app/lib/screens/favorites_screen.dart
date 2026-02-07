import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/favorites/favorites_cubit.dart';
import '../cubits/favorites/favorites_state.dart';
import '../di/service_locator.dart';
import 'package:dancee_shared/dancee_shared.dart';
import '../i18n/translations.g.dart';
import '../widgets/event_card.dart';

class FavoritesScreen extends StatefulWidget {
  final ValueNotifier<int>? reloadTrigger;
  final VoidCallback? onNavigateToEvents;
  
  const FavoritesScreen({super.key, this.reloadTrigger, this.onNavigateToEvents});

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
                  final event = upcomingEvents[index];
                  return EventCard(
                    event: event,
                    onTap: () {
                      // TODO: Navigate to event detail
                    },
                    onFavoriteToggle: () {
                      getIt<FavoritesCubit>().toggleFavorite(event.id);
                    },
                  );
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
                  final event = pastEvents[index];
                  return EventCard(
                    event: event,
                    onTap: () {
                      // TODO: Navigate to event detail
                    },
                    onFavoriteToggle: () {
                      getIt<FavoritesCubit>().removePastEvent(event.id);
                    },
                    enableDismiss: true,
                    onDismissed: () {
                      getIt<FavoritesCubit>().removePastEvent(event.id);
                    },
                  );
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
                  onTap: widget.onNavigateToEvents,
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