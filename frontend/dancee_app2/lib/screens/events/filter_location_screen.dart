import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/colors.dart';
import '../../core/theme.dart';

class FilterLocationScreen extends StatefulWidget {
  const FilterLocationScreen({super.key});

  @override
  State<FilterLocationScreen> createState() => _FilterLocationScreenState();
}

class _FilterLocationScreenState extends State<FilterLocationScreen> {
  final TextEditingController _searchController = TextEditingController();

  static const _popularCities = [
    _City(
      name: 'Praha',
      eventCount: '125 nadcházejících akcí',
      gradientStart: appPrimary,
      gradientEnd: appAccent,
      icon: FontAwesomeIcons.building,
      isCurrent: true,
    ),
    _City(
      name: 'Brno',
      eventCount: '47 nadcházejících akcí',
      gradientStart: appEmerald,
      gradientEnd: appTealDark,
      icon: FontAwesomeIcons.city,
      isCurrent: false,
    ),
    _City(
      name: 'Ostrava',
      eventCount: '23 nadcházejících akcí',
      gradientStart: appWarning,
      gradientEnd: appError,
      icon: FontAwesomeIcons.industry,
      isCurrent: false,
    ),
    _City(
      name: 'Plzeň',
      eventCount: '18 nadcházejících akcí',
      gradientStart: appYellow,
      gradientEnd: appAmberDark,
      icon: FontAwesomeIcons.beerMugEmpty,
      isCurrent: false,
    ),
  ];

  static const _allCities = [
    _CitySimple(name: 'Bratislava, SK', count: '12 akcí'),
    _CitySimple(name: 'České Budějovice', count: '8 akcí'),
    _CitySimple(name: 'Hradec Králové', count: '6 akcí'),
    _CitySimple(name: 'Jihlava', count: '4 akce'),
    _CitySimple(name: 'Karlovy Vary', count: '3 akce'),
    _CitySimple(name: 'Liberec', count: '9 akcí'),
    _CitySimple(name: 'Olomouc', count: '14 akcí'),
    _CitySimple(name: 'Pardubice', count: '5 akcí'),
    _CitySimple(name: 'Ústí nad Labem', count: '7 akcí'),
    _CitySimple(name: 'Zlín', count: '11 akcí'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCurrentLocation(),
                  const SizedBox(height: 32),
                  _buildPopularCities(),
                  const SizedBox(height: 32),
                  _buildAllCities(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
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
        color: appBg.withValues(alpha: 0.9),
        border: const Border(bottom: BorderSide(color: appBorder)),
      ),
      child: Column(
        children: [
          Row(
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
              const Text(
                'Vybrat lokalitu',
                style: TextStyle(
                  fontSize: AppTypography.fontSize3xl,
                  fontWeight: FontWeight.bold,
                  color: appText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: appSurface,
              border: Border.all(color: appBorder),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Icon(FontAwesomeIcons.magnifyingGlass, size: 14, color: appMuted),
                ),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(fontSize: AppTypography.fontSizeMd, color: appText),
                    decoration: const InputDecoration(
                      hintText: 'Hledat město nebo oblast...',
                      hintStyle: TextStyle(fontSize: AppTypography.fontSizeMd, color: appMuted),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentLocation() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: appSurface,
          border: Border.all(color: appBorder),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: appPrimary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(FontAwesomeIcons.locationCrosshairs, size: 20, color: appPrimary),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Použít moji polohu',
                    style: TextStyle(
                      fontSize: AppTypography.fontSizeLg,
                      fontWeight: AppTypography.fontWeightSemiBold,
                      color: appText,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Automaticky najde akce ve vašem okolí',
                    style: TextStyle(fontSize: AppTypography.fontSizeMd, color: appMuted),
                  ),
                ],
              ),
            ),
            const Icon(FontAwesomeIcons.chevronRight, size: 14, color: appMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularCities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Oblíbená města',
          style: TextStyle(
            fontSize: AppTypography.fontSize2xl,
            fontWeight: FontWeight.bold,
            color: appText,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: _popularCities.map((city) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildPopularCityCard(city),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildPopularCityCard(_City city) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: appSurface,
          border: Border.all(color: appBorder),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [city.gradientStart, city.gradientEnd],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(city.icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    city.name,
                    style: const TextStyle(
                      fontSize: AppTypography.fontSizeLg,
                      fontWeight: AppTypography.fontWeightSemiBold,
                      color: appText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    city.eventCount,
                    style: const TextStyle(fontSize: AppTypography.fontSizeMd, color: appMuted),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                if (city.isCurrent) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: appPrimary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: const Text(
                      'Aktuální',
                      style: TextStyle(
                        fontSize: AppTypography.fontSizeSm,
                        fontWeight: AppTypography.fontWeightMedium,
                        color: appPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                const Icon(FontAwesomeIcons.chevronRight, size: 14, color: appMuted),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllCities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Všechna města',
          style: TextStyle(
            fontSize: AppTypography.fontSize2xl,
            fontWeight: FontWeight.bold,
            color: appText,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: _allCities.map((city) => _buildCityRow(city)).toList(),
        ),
      ],
    );
  }

  Widget _buildCityRow(_CitySimple city) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              city.name,
              style: const TextStyle(fontSize: AppTypography.fontSizeLg, color: appText),
            ),
            Text(
              city.count,
              style: const TextStyle(fontSize: AppTypography.fontSizeMd, color: appMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: appCard,
        border: Border(top: BorderSide(color: appBorder)),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 8,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navItem(FontAwesomeIcons.house, 'Domů', false, solid: true, onTap: () => context.go('/events')),
          _navItem(FontAwesomeIcons.magnifyingGlass, 'Hledat', false, onTap: () {}),
          _navFab(),
          _navItem(FontAwesomeIcons.heart, 'Uložené', false, onTap: () {}),
          _navItem(FontAwesomeIcons.user, 'Profil', false, onTap: () {}),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active, {bool solid = false, VoidCallback? onTap}) {
    final color = active ? appPrimary : appMuted;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: AppTypography.fontSizeXs, fontWeight: AppTypography.fontWeightMedium, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _navFab() {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: appPrimary,
          shape: BoxShape.circle,
          border: Border.all(color: appBg, width: 4),
          boxShadow: [
            AppShadows.primaryLg,
          ],
        ),
        child: const Icon(FontAwesomeIcons.plus, color: Colors.white, size: 20),
      ),
    );
  }
}

class _City {
  final String name;
  final String eventCount;
  final Color gradientStart;
  final Color gradientEnd;
  final IconData icon;
  final bool isCurrent;

  const _City({
    required this.name,
    required this.eventCount,
    required this.gradientStart,
    required this.gradientEnd,
    required this.icon,
    required this.isCurrent,
  });
}

class _CitySimple {
  final String name;
  final String count;

  const _CitySimple({required this.name, required this.count});
}
