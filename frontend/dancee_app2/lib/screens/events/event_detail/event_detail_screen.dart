import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';
import '../../../data/entities/event.dart';
import '../../../data/entities/event_info.dart';
import '../../../data/entities/event_part.dart';
import '../../../i18n/strings.g.dart';
import '../../../logic/cubits/event_cubit.dart';
import '../../../logic/cubits/favorites_cubit.dart';
import '../../../logic/states/event_state.dart';
import '../../../shared/sections/description_section.dart';
import '../../../shared/utils/date_format.dart';
import '../../../shared/sections/detail_header_section.dart';
import '../../../shared/sections/hero_image_section.dart';
import '../../../shared/sections/key_info_section.dart';
import 'sections/action_buttons_section.dart';
import 'sections/additional_info_section.dart';
import 'sections/event_program_section.dart';
import 'sections/event_title_section.dart';

class EventDetailScreen extends StatelessWidget {
  final int eventId;

  const EventDetailScreen({super.key, required this.eventId});

  List<KeyInfoItem> _buildKeyInfo(Event event) {
    final items = <KeyInfoItem>[];

    // Date/time
    final dateStr = formatDate(event.startTime);
    final timeStr = formatTime(event.startTime);
    final endStr = event.endTime != null ? ' – ${formatTime(event.endTime!)}' : '';
    items.add(KeyInfoItem(
      icon: FontAwesomeIcons.calendar,
      title: dateStr,
      subtitle: '$timeStr$endStr',
    ));

    // Venue
    if (event.venue != null) {
      items.add(KeyInfoItem(
        icon: FontAwesomeIcons.locationDot,
        title: event.venue!.name,
        subtitle: event.venue!.fullAddress,
      ));
    }

    // Organizer
    if (event.organizer.isNotEmpty) {
      items.add(KeyInfoItem(
        icon: FontAwesomeIcons.user,
        title: event.organizer,
        subtitle: '',
      ));
    }

    // Additional info items (url type shown as key info)
    for (final info in event.info) {
      if (info.type == EventInfoType.url && info.key.isNotEmpty) {
        items.add(KeyInfoItem(
          icon: FontAwesomeIcons.link,
          title: info.key,
          subtitle: info.value,
        ));
      }
    }

    return items;
  }

  List<ProgramDayData> _buildProgram(List<EventPart> parts) {
    if (parts.isEmpty) return [];

    // Group parts by date
    final Map<String, List<EventPart>> byDate = {};
    for (final part in parts) {
      final key = part.startTime != null
          ? formatDate(part.startTime!)
          : t.events.detail.program;
      byDate.putIfAbsent(key, () => []).add(part);
    }

    return byDate.entries.map((entry) {
      return ProgramDayData(
        day: entry.key,
        slots: entry.value.map((part) {
          final timeStr = part.startTime != null
              ? formatTime(part.startTime!)
              : '';
          final extras = [
            ...part.lectors.map((l) => t.events.detail.lector(name: l)),
            ...part.djs.map((dj) => t.events.detail.dj(name: dj)),
          ].join(', ');
          return ProgramSlotData(
            time: timeStr,
            title: part.name,
            description: part.description ?? '',
            extra: extras.isNotEmpty ? extras : null,
            extraColor: appPrimary,
          );
        }).toList(),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      body: Column(
        children: [
          DetailHeaderSection(
            title: t.events.detail.header,
            onBack: () => context.pop(),
          ),
          Expanded(
            child: BlocBuilder<EventCubit, EventState>(
              builder: (context, state) {
                final event = state.maybeMap(
                  loaded: (s) => s.allEvents
                      .where((e) => e.id == eventId)
                      .firstOrNull,
                  orElse: () => null,
                );

                if (event == null) {
                  return state.maybeMap(
                    loading: (_) => const Center(
                      child: CircularProgressIndicator(color: appPrimary),
                    ),
                    orElse: () => Center(
                      child: Text(
                        t.events.detail.notFound,
                        style: const TextStyle(color: appMuted),
                      ),
                    ),
                  );
                }

                final priceInfo = event.info
                    .where((i) => i.type == EventInfoType.price)
                    .firstOrNull;
                final dresscodeInfo = event.info
                    .where((i) => i.type == EventInfoType.dresscode)
                    .firstOrNull;

                final priceRange = priceInfo?.value ?? '';
                final dresscode = dresscodeInfo?.value ?? '';

                return BlocBuilder<FavoritesCubit, dynamic>(
                  builder: (context, _) {
                    final isFavorited = context
                        .read<FavoritesCubit>()
                        .isFavorited('event', event.id);

                    return SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 100),
                      child: Column(
                        children: [
                          HeroImageSection(
                            imageUrl: event.imageUrl ?? '',
                            topLeft: priceRange.isNotEmpty
                                ? HeroPriceBadge(price: priceRange)
                                : null,
                            topRight: HeroFavoriteButton(
                              isFavorite: isFavorited,
                              onTap: () =>
                                  context.read<FavoritesCubit>().toggleFavorite(
                                        itemType: 'event',
                                        itemId: event.id,
                                      ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: AppSpacing.xxl),
                                EventTitleSection(
                                  title: event.title,
                                  chips: event.dances
                                      .map((d) => EventTitleChip(
                                            label: d,
                                            color: appPrimary,
                                          ))
                                      .toList(),
                                ),
                                const SizedBox(height: AppSpacing.xxl),
                                KeyInfoSection(
                                  items: _buildKeyInfo(event),
                                ),
                                const SizedBox(height: AppSpacing.xxl),
                                ActionButtonsSection(
                                  onSave: () =>
                                      context.read<FavoritesCubit>().toggleFavorite(
                                            itemType: 'event',
                                            itemId: event.id,
                                          ),
                                  onShare: null,
                                  onMap: null,
                                ),
                                const SizedBox(height: AppSpacing.xxl),
                                if (event.description.isNotEmpty)
                                  DescriptionSection(
                                    title: t.events.detail.description,
                                    paragraphs: event.description
                                        .split('\n\n')
                                        .where((p) => p.trim().isNotEmpty)
                                        .toList(),
                                  ),
                                if (event.description.isNotEmpty)
                                  const SizedBox(height: AppSpacing.xxl),
                                AdditionalInfoSection(
                                  priceRange: priceRange,
                                  dresscode: dresscode,
                                  onBuyTickets: event.registrationUrl != null
                                      ? () {}
                                      : null,
                                  onSource: event.originalUrl != null ? () {} : null,
                                ),
                                if (event.parts.isNotEmpty) ...[
                                  const SizedBox(height: AppSpacing.xxl),
                                  EventProgramSection(
                                    days: _buildProgram(event.parts),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
