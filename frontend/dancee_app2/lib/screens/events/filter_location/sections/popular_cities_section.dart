import 'package:flutter/material.dart';
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

class PopularCitiesSection extends StatelessWidget {
  final List<PopularCityData> cities;
  final ValueChanged<PopularCityData>? onCityTap;

  const PopularCitiesSection({
    super.key,
    required this.cities,
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
