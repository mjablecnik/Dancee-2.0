import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/colors.dart';
import '../../core/theme.dart';

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
    _DanceStyle(
      name: 'Salsa',
      subtitle: 'Kubánská, On1, On2',
      icon: FontAwesomeIcons.music,
      gradientStart: appPrimary,
      gradientEnd: appPrimaryDark,
    ),
    _DanceStyle(
      name: 'Bachata',
      subtitle: 'Sensual, Dominicana',
      icon: FontAwesomeIcons.heart,
      gradientStart: appAccent,
      gradientEnd: appPink,
    ),
    _DanceStyle(
      name: 'Kizomba',
      subtitle: 'Urban Kiz, Semba',
      icon: FontAwesomeIcons.fire,
      gradientStart: appViolet,
      gradientEnd: appVioletDark,
    ),
    _DanceStyle(
      name: 'Zouk',
      subtitle: 'Brazilian Zouk, Lambada',
      icon: FontAwesomeIcons.leaf,
      gradientStart: appEmerald,
      gradientEnd: appSuccessDark,
    ),
    _DanceStyle(
      name: 'Reggaeton',
      subtitle: 'Urban Latin',
      icon: FontAwesomeIcons.fireFlameSimple,
      gradientStart: appWarning,
      gradientEnd: appError,
    ),
    _DanceStyle(
      name: 'Tango',
      subtitle: 'Argentinské, Ballroom',
      icon: FontAwesomeIcons.bolt,
      gradientStart: appYellow,
      gradientEnd: appAmberDark,
    ),
    _DanceStyle(
      name: 'Swing',
      subtitle: 'Lindy Hop, Charleston',
      icon: FontAwesomeIcons.crown,
      gradientStart: appCyan,
      gradientEnd: appPrimary,
    ),
    _DanceStyle(
      name: 'Ballroom',
      subtitle: 'Standardní, Latinsko-americké',
      icon: FontAwesomeIcons.star,
      gradientStart: appPink,
      gradientEnd: appRose,
    ),
    _DanceStyle(
      name: 'Afro',
      subtitle: 'Afrohouse, Kuduro',
      icon: FontAwesomeIcons.drum,
      gradientStart: appIndigo,
      gradientEnd: appPurple,
    ),
    _DanceStyle(
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
    final selectedStyles = _selected.entries.where((e) => e.value).map((e) => e.key).toList();

    return Scaffold(
      backgroundColor: appBg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStylesList(),
                  if (selectedStyles.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSelectedSection(selectedStyles),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomActions(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 16,
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Taneční styly',
                  style: TextStyle(
                    fontSize: AppTypography.fontSize3xl,
                    fontWeight: FontWeight.bold,
                    color: appText,
                  ),
                ),
                Text(
                  _selectedCountText,
                  style: const TextStyle(fontSize: AppTypography.fontSizeMd, color: appMuted),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _clearAll,
            child: const Text(
              'Vymazat',
              style: TextStyle(fontSize: AppTypography.fontSizeMd, fontWeight: AppTypography.fontWeightMedium, color: appPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStylesList() {
    return Container(
      decoration: BoxDecoration(
        color: appSurface,
        border: Border.all(color: appBorder),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(_styles.length, (index) {
          final style = _styles[index];
          final isLast = index == _styles.length - 1;
          return _buildStyleRow(style, isLast);
        }),
      ),
    );
  }

  Widget _buildStyleRow(_DanceStyle style, bool isLast) {
    final isChecked = _selected[style.name] ?? false;
    return InkWell(
      onTap: () {
        setState(() {
          _selected[style.name] = !isChecked;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: isLast ? null : const Border(bottom: BorderSide(color: appBorder)),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [style.gradientStart, style.gradientEnd],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(style.icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    style.name,
                    style: const TextStyle(
                      fontSize: AppTypography.fontSizeXl,
                      fontWeight: AppTypography.fontWeightSemiBold,
                      color: appText,
                    ),
                  ),
                  Text(
                    style.subtitle,
                    style: const TextStyle(fontSize: AppTypography.fontSizeSm, color: appMuted),
                  ),
                ],
              ),
            ),
            _buildCheckbox(isChecked, style.name),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(bool isChecked, String styleName) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selected[styleName] = !isChecked;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isChecked ? appPrimary : appSurface,
          border: Border.all(
            color: isChecked ? appPrimary : appBorder,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: isChecked
            ? const Icon(FontAwesomeIcons.check, size: 12, color: Colors.white)
            : null,
      ),
    );
  }

  Widget _buildSelectedSection(List<String> selectedStyles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'VYBRANÉ STYLY',
          style: TextStyle(
            fontSize: AppTypography.fontSizeSm,
            fontWeight: AppTypography.fontWeightSemiBold,
            color: appMuted,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: selectedStyles.map((style) => _buildSelectedTag(style)).toList(),
        ),
      ],
    );
  }

  Widget _buildSelectedTag(String style) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: appPrimary.withValues(alpha: 0.2),
        border: Border.all(color: appPrimary.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            style,
            style: const TextStyle(
              fontSize: AppTypography.fontSizeMd,
              fontWeight: AppTypography.fontWeightMedium,
              color: appPrimary,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _selected[style] = false;
              });
            },
            child: const Icon(FontAwesomeIcons.xmark, size: 12, color: appPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    final count = _selectedCount;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            appBg.withValues(alpha: 0),
            appBg,
            appBg,
          ],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        24,
        20,
        MediaQuery.of(context).padding.bottom + 32,
      ),
      child: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: appPrimary,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [
              AppShadows.primaryLg,
            ],
          ),
          child: Text(
            count > 0 ? 'Použít filtr ($count)' : 'Použít filtr',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: AppTypography.fontSizeXl,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _DanceStyle {
  final String name;
  final String subtitle;
  final IconData icon;
  final Color gradientStart;
  final Color gradientEnd;

  const _DanceStyle({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.gradientStart,
    required this.gradientEnd,
  });
}
