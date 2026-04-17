import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../components/popular_city_card.dart';

class PopularCityData {
  final String name;
  final String eventCount;
  final Color gradientStart;
  final Color gradientEnd;
  final IconData icon;
  final bool isCurrent;

  const PopularCityData({
    required this.name,
    required this.eventCount,
    required this.gradientStart,
    required this.gradientEnd,
    required this.icon,
    this.isCurrent = false,
  });
}

const _defaultCities = [
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

class PopularCitiesSection extends StatelessWidget {
  final List<PopularCityData> cities;
  final ValueChanged<PopularCityData>? onCityTap;

  const PopularCitiesSection({
    super.key,
    this.cities = _defaultCities,
    this.onCityTap,
  });

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(height: AppSpacing.lg),
        Column(
          children: cities
              .map((city) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: PopularCityCard(
                      name: city.name,
                      eventCount: city.eventCount,
                      gradientStart: city.gradientStart,
                      gradientEnd: city.gradientEnd,
                      icon: city.icon,
                      isCurrent: city.isCurrent,
                      onTap: () => onCityTap?.call(city),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
