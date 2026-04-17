import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/colors.dart';
import '../../core/theme.dart';
import 'filter_dance/sections/dance_styles_list_section.dart';
import 'filter_dance/sections/filter_bottom_actions_section.dart';
import 'filter_dance/sections/selected_styles_section.dart';

class FilterDanceScreen extends StatefulWidget {
  const FilterDanceScreen({super.key});

  @override
  State<FilterDanceScreen> createState() => _FilterDanceScreenState();
}

class _FilterDanceScreenState extends State<FilterDanceScreen> {
  final Map<String, bool> _selected = {
    'Salsa': false,
    'Bachata': false,
    'Kizomba': false,
    'Zouk': false,
    'Reggaeton': false,
    'Tango': false,
    'Swing': false,
    'Ballroom': false,
    'Afro': false,
    'Forró': false,
  };

  static const _styles = [
    DanceStyleItem(
      name: 'Salsa',
      subtitle: 'Kubánská, On1, On2',
      icon: FontAwesomeIcons.music,
      gradientStart: appPrimary,
      gradientEnd: appPrimaryDark,
    ),
    DanceStyleItem(
      name: 'Bachata',
      subtitle: 'Sensual, Dominicana',
      icon: FontAwesomeIcons.heart,
      gradientStart: appAccent,
      gradientEnd: appPink,
    ),
    DanceStyleItem(
      name: 'Kizomba',
      subtitle: 'Urban Kiz, Semba',
      icon: FontAwesomeIcons.fire,
      gradientStart: appViolet,
      gradientEnd: appVioletDark,
    ),
    DanceStyleItem(
      name: 'Zouk',
      subtitle: 'Brazilian Zouk, Lambada',
      icon: FontAwesomeIcons.leaf,
      gradientStart: appEmerald,
      gradientEnd: appSuccessDark,
    ),
    DanceStyleItem(
      name: 'Reggaeton',
      subtitle: 'Urban Latin',
      icon: FontAwesomeIcons.fireFlameSimple,
      gradientStart: appWarning,
      gradientEnd: appError,
    ),
    DanceStyleItem(
      name: 'Tango',
      subtitle: 'Argentinské, Ballroom',
      icon: FontAwesomeIcons.bolt,
      gradientStart: appYellow,
      gradientEnd: appAmberDark,
    ),
    DanceStyleItem(
      name: 'Swing',
      subtitle: 'Lindy Hop, Charleston',
      icon: FontAwesomeIcons.crown,
      gradientStart: appCyan,
      gradientEnd: appPrimary,
    ),
    DanceStyleItem(
      name: 'Ballroom',
      subtitle: 'Standardní, Latinsko-americké',
      icon: FontAwesomeIcons.star,
      gradientStart: appPink,
      gradientEnd: appRose,
    ),
    DanceStyleItem(
      name: 'Afro',
      subtitle: 'Afrohouse, Kuduro',
      icon: FontAwesomeIcons.drum,
      gradientStart: appIndigo,
      gradientEnd: appPurple,
    ),
    DanceStyleItem(
      name: 'Forró',
      subtitle: 'Brazilský lidový tanec',
      icon: FontAwesomeIcons.umbrellaBeach,
      gradientStart: appError,
      gradientEnd: appHotPink,
    ),
  ];

  int get _selectedCount => _selected.values.where((v) => v).length;

  String get _selectedCountText {
    final count = _selectedCount;
    if (count == 0) return '0 vybraných';
    if (count == 1) return '1 vybraný';
    if (count < 5) return '$count vybrané';
    return '$count vybraných';
  }

  void _clearAll() {
    setState(() {
      for (final key in _selected.keys) {
        _selected[key] = false;
      }
    });
  }

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
          _buildHeader(context),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.md,
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: appBg.withValues(alpha: 0.95),
        border: const Border(bottom: BorderSide(color: appBorder)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: appSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(FontAwesomeIcons.arrowLeft, size: 16, color: appText),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Taneční styly',
                  style: TextStyle(
                    fontSize: AppTypography.fontSize3xl,
                    fontWeight: AppTypography.fontWeightBold,
                    color: appText,
                  ),
                ),
                Text(
                  _selectedCountText,
                  style: const TextStyle(
                    fontSize: AppTypography.fontSizeMd,
                    color: appMuted,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _clearAll,
            child: const Text(
              'Vymazat',
              style: TextStyle(
                fontSize: AppTypography.fontSizeMd,
                fontWeight: AppTypography.fontWeightMedium,
                color: appPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
