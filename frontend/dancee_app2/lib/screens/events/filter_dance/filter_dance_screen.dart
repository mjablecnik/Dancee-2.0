import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';
import '../../../data/event_repository.dart';
import '../../../i18n/strings.g.dart';
import 'sections/dance_styles_list_section.dart';
import 'sections/filter_bottom_actions_section.dart';
import 'sections/filter_dance_header_section.dart';
import 'sections/selected_styles_section.dart';

class FilterDanceScreen extends StatefulWidget {
  const FilterDanceScreen({super.key});

  @override
  State<FilterDanceScreen> createState() => _FilterDanceScreenState();
}

class _FilterDanceScreenState extends State<FilterDanceScreen> {
  List<DanceStyleData> _styles = [];
  Map<String, bool> _selected = {};

  @override
  void initState() {
    super.initState();
    const EventRepository().getDanceStyles().then((styles) {
      if (mounted) {
        setState(() {
          _styles = styles;
          _selected = {for (final s in styles) s.name: false};
        });
      }
    });
  }

  int get _selectedCount => _selected.values.where((v) => v).length;

  String get _selectedCountText {
    final count = _selectedCount;
    return t.events.filter.selectedCount(count: count);
  }

  void _clearAll() => setState(() {
    for (final key in _selected.keys) {
      _selected[key] = false;
    }
  });

  @override
  Widget build(BuildContext context) {
    final selectedStyles = _selected.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    return Scaffold(
      backgroundColor: appBg,
      body: Column(
        children: [
          FilterDanceHeaderSection(
            selectedCountText: _selectedCountText,
            onBack: () => context.pop(),
            onClear: _clearAll,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xxl,
                AppSpacing.xl,
                120,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DanceStylesListSection(
                    styles: _styles,
                    selected: _selected,
                    onToggle: (name) => setState(
                      () => _selected[name] = !(_selected[name] ?? false),
                    ),
                  ),
                  if (selectedStyles.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxl),
                    SelectedStylesSection(
                      selectedStyles: selectedStyles,
                      onRemove: (style) =>
                          setState(() => _selected[style] = false),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: FilterBottomActionsSection(
        selectedCount: _selectedCount,
        onApply: () => context.pop(),
      ),
    );
  }
}
