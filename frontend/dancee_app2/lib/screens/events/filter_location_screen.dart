import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/colors.dart';
import '../../core/theme.dart';
import '../../shared/elements/navigation/app_bottom_nav_bar.dart';
import 'filter_location/sections/all_cities_section.dart';
import 'filter_location/sections/current_location_section.dart';
import 'filter_location/sections/popular_cities_section.dart';

class FilterLocationScreen extends StatefulWidget {
  const FilterLocationScreen({super.key});

  @override
  State<FilterLocationScreen> createState() => _FilterLocationScreenState();
}

class _FilterLocationScreenState extends State<FilterLocationScreen> {
  final TextEditingController _searchController = TextEditingController();

  static const _popularCities = [
    PopularCityData(
      name: 'Praha',
      eventCount: '125 nadcházejících akcí',
      gradientStart: appPrimary,
      gradientEnd: appAccent,
      icon: FontAwesomeIcons.building,
      isCurrent: true,
    ),
    PopularCityData(
      name: 'Brno',
      eventCount: '47 nadcházejících akcí',
      gradientStart: appEmerald,
      gradientEnd: appTealDark,
      icon: FontAwesomeIcons.city,
    ),
    PopularCityData(
      name: 'Ostrava',
      eventCount: '23 nadcházejících akcí',
      gradientStart: appWarning,
      gradientEnd: appError,
      icon: FontAwesomeIcons.industry,
    ),
    PopularCityData(
      name: 'Plzeň',
      eventCount: '18 nadcházejících akcí',
      gradientStart: appYellow,
      gradientEnd: appAmberDark,
      icon: FontAwesomeIcons.beerMugEmpty,
    ),
  ];

  static const _allCities = [
    CityData(name: 'Bratislava, SK', count: '12 akcí'),
    CityData(name: 'České Budějovice', count: '8 akcí'),
    CityData(name: 'Hradec Králové', count: '6 akcí'),
    CityData(name: 'Jihlava', count: '4 akce'),
    CityData(name: 'Karlovy Vary', count: '3 akce'),
    CityData(name: 'Liberec', count: '9 akcí'),
    CityData(name: 'Olomouc', count: '14 akcí'),
    CityData(name: 'Pardubice', count: '5 akcí'),
    CityData(name: 'Ústí nad Labem', count: '7 akcí'),
    CityData(name: 'Zlín', count: '11 akcí'),
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
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xxl,
                AppSpacing.xl,
                96,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CurrentLocationSection(onTap: () {}),
                  const SizedBox(height: AppSpacing.xxxl),
                  PopularCitiesSection(
                    cities: _popularCities,
                    onCityTap: (_) {},
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  AllCitiesSection(
                    cities: _allCities,
                    onCityTap: (_) {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        leftItems: [
          AppNavBarItem(
            icon: FontAwesomeIcons.house,
            label: 'Domů',
            onTap: () => context.go('/events'),
          ),
          AppNavBarItem(
            icon: FontAwesomeIcons.magnifyingGlass,
            label: 'Hledat',
          ),
        ],
        rightItems: [
          AppNavBarItem(
            icon: FontAwesomeIcons.heart,
            label: 'Uložené',
          ),
          AppNavBarItem(
            icon: FontAwesomeIcons.user,
            label: 'Profil',
          ),
        ],
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
              const SizedBox(width: AppSpacing.lg),
              const Text(
                'Vybrat lokalitu',
                style: TextStyle(
                  fontSize: AppTypography.fontSize3xl,
                  fontWeight: AppTypography.fontWeightBold,
                  color: appText,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            decoration: BoxDecoration(
              color: appSurface,
              border: Border.all(color: appBorder),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: AppSpacing.lg),
                  child: Icon(FontAwesomeIcons.magnifyingGlass, size: 14, color: appMuted),
                ),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(
                      fontSize: AppTypography.fontSizeMd,
                      color: appText,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Hledat město nebo oblast...',
                      hintStyle: TextStyle(
                        fontSize: AppTypography.fontSizeMd,
                        color: appMuted,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 14,
                      ),
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
}
