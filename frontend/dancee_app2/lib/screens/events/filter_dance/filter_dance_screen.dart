import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';
import '../../../data/entities/dance_style.dart';
import '../../../i18n/strings.g.dart';
import '../../../logic/cubits/filter_cubit.dart';
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
  List<DanceStyle> _styles = [];
  Map<String, bool> _selected = {}; // key = dance style code

  @override
  void initState() {
    super.initState();
    final filterCubit = context.read<FilterCubit>();
    _styles = filterCubit.parentDanceStyles;
    final alreadySelected = filterCubit.state.selectedDanceStyles;
    _selected = {
      for (final s in _styles) s.code: alreadySelected.contains(s.code),
    };
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

  List<String> get _selectedStyleNames => _selected.entries
      .where((e) => e.value)
      .map((e) {
        final style = _styles.firstWhere(
          (s) => s.code == e.key,
          orElse: () => DanceStyle(code: e.key, name: e.key, sortOrder: 0),
        );
        return style.name;
      })
      .toList();

  void _removeByName(String name) {
    final style = _styles.firstWhere(
      (s) => s.name == name,
      orElse: () => DanceStyle(code: '', name: name, sortOrder: 0),
    );
    if (style.code.isNotEmpty) {
      setState(() => _selected[style.code] = false);
    }
  }

  void _apply() {
    final codes = _selected.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toSet();
    context.read<FilterCubit>().setDanceStyles(codes);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final selectedNames = _selectedStyleNames;

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
                    onToggle: (code) =>
                        setState(() => _selected[code] = !(_selected[code] ?? false)),
                  ),
                  if (selectedNames.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxl),
                    SelectedStylesSection(
                      selectedStyles: selectedNames,
                      onRemove: _removeByName,
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
        onApply: _apply,
      ),
    );
  }
}
