import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dancee_shared/dancee_shared.dart';
import '../i18n/translations.g.dart';

/// Reusable event card widget used in both event list and favorites screens.
///
/// Displays event information including title, venue, date, time, and dance tags.
/// Supports favorite toggling and optional swipe-to-delete for past events.
class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final bool enableDismiss;
  final VoidCallback? onDismissed;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.onFavoriteToggle,
    this.enableDismiss = false,
    this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = _buildCardContent(context);

    // Wrap past events in Dismissible for swipe-to-delete animation
    if (enableDismiss && event.isPast && onDismissed != null) {
      return Dismissible(
        key: Key(event.id),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) => onDismissed!(),
        background: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.red[400],
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(
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

  Widget _buildCardContent(BuildContext context) {
    final dateFormat = _formatDate(event.startTime);
    final timeFormat = _formatTime(event.startTime, event.endTime);
    final gradientColors = _getGradientColors(event.dances.isNotEmpty ? event.dances.first : '');

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
          onTap: event.isPast ? null : onTap,
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
                        child: Icon(
                          _getEventIcon(event.dances),
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
                                  onTap: onFavoriteToggle,
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
      case 'romantica':
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

  IconData _getEventIcon(List<String> dances) {
    if (dances.isEmpty) return Icons.music_note;

    final primaryDance = dances.first.toLowerCase();
    switch (primaryDance) {
      case 'salsa':
        return Icons.local_fire_department;
      case 'bachata':
        return Icons.favorite;
      case 'kizomba':
        return Icons.nightlight_round;
      case 'zouk':
      case 'brazilian zouk':
        return Icons.water_drop;
      case 'tango':
      case 'argentine tango':
        return Icons.wb_sunny;
      case 'merengue':
        return Icons.celebration;
      case 'reggaeton':
        return Icons.music_note;
      default:
        return Icons.music_note;
    }
  }
}
