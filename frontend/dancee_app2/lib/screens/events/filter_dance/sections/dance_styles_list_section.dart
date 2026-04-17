import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';

class DanceStyleItem {
  final String name;
  final String subtitle;
  final IconData icon;
  final Color gradientStart;
  final Color gradientEnd;

  const DanceStyleItem({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.gradientStart,
    required this.gradientEnd,
  });
}

const _defaultStyles = [
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

class DanceStylesListSection extends StatelessWidget {
  final List<DanceStyleItem> styles;
  final Map<String, bool> selected;
  final ValueChanged<String> onToggle;

  const DanceStylesListSection({
    super.key,
    this.styles = _defaultStyles,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appSurface,
        border: Border.all(color: appBorder),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(styles.length, (index) {
          final style = styles[index];
          final isLast = index == styles.length - 1;
          final isChecked = selected[style.name] ?? false;
          return _StyleRow(
            style: style,
            isChecked: isChecked,
            isLast: isLast,
            onToggle: () => onToggle(style.name),
          );
        }),
      ),
    );
  }
}

class _StyleRow extends StatelessWidget {
  final DanceStyleItem style;
  final bool isChecked;
  final bool isLast;
  final VoidCallback onToggle;

  const _StyleRow({
    required this.style,
    required this.isChecked,
    required this.isLast,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Container(
        decoration: BoxDecoration(
          border: isLast ? null : const Border(bottom: BorderSide(color: appBorder)),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
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
            const SizedBox(width: AppSpacing.md),
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
            _Checkbox(isChecked: isChecked, onToggle: onToggle),
          ],
        ),
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  final bool isChecked;
  final VoidCallback onToggle;

  const _Checkbox({required this.isChecked, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
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
}
