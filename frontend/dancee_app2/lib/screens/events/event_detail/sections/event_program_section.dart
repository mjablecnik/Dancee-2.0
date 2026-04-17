import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';

class ProgramSlotData {
  final String time;
  final String title;
  final String description;
  final String? extra;
  final Color? extraColor;

  const ProgramSlotData({
    required this.time,
    required this.title,
    required this.description,
    this.extra,
    this.extraColor,
  });
}

class ProgramDayData {
  final String day;
  final List<ProgramSlotData> slots;

  const ProgramDayData({required this.day, required this.slots});
}

class EventProgramSection extends StatefulWidget {
  final List<ProgramDayData> days;

  const EventProgramSection({super.key, required this.days});

  @override
  State<EventProgramSection> createState() => _EventProgramSectionState();
}

class _EventProgramSectionState extends State<EventProgramSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Program akce',
                style: TextStyle(
                  color: appText,
                  fontSize: AppTypography.fontSize2xl,
                  fontWeight: AppTypography.fontWeightBold,
                ),
              ),
              AnimatedRotation(
                turns: _expanded ? 0 : -0.25,
                duration: const Duration(milliseconds: 300),
                child: const FaIcon(FontAwesomeIcons.chevronDown, size: 16, color: appText),
              ),
            ],
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: AppSpacing.lg),
          for (int i = 0; i < widget.days.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            _DayCard(day: widget.days[i]),
          ],
        ],
      ],
    );
  }
}

class _DayCard extends StatelessWidget {
  final ProgramDayData day;

  const _DayCard({required this.day});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appSurface,
        border: Border.all(color: appBorder),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              color: appCard,
              border: Border(bottom: BorderSide(color: appBorder)),
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
            ),
            child: Text(
              day.day,
              style: const TextStyle(
                color: appText,
                fontSize: AppTypography.fontSizeLg,
                fontWeight: AppTypography.fontWeightBold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                for (int i = 0; i < day.slots.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.lg),
                  _SlotItem(slot: day.slots[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotItem extends StatelessWidget {
  final ProgramSlotData slot;

  const _SlotItem({required this.slot});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 64,
          child: Text(
            slot.time,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: appMuted,
              fontSize: AppTypography.fontSizeSm,
              fontWeight: AppTypography.fontWeightMedium,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                slot.title,
                style: const TextStyle(
                  color: appText,
                  fontSize: AppTypography.fontSizeMd,
                  fontWeight: AppTypography.fontWeightSemiBold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                slot.description,
                style: const TextStyle(color: appMuted, fontSize: AppTypography.fontSizeSm),
              ),
              if (slot.extra != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  slot.extra!,
                  style: TextStyle(
                    color: slot.extraColor,
                    fontSize: AppTypography.fontSizeSm,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
