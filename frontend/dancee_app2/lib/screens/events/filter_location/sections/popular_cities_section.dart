import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../data/city_repository.dart';
import '../../../../i18n/strings.g.dart';
import '../components/popular_city_card.dart';

class PopularCitiesSection extends StatelessWidget {
  final ValueChanged<PopularCityData>? onCityTap;

  const PopularCitiesSection({
    super.key,
    this.onCityTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.events.filter.popularCities,
          style: const TextStyle(
            fontSize: AppTypography.fontSize2xl,
            fontWeight: FontWeight.bold,
            color: appText,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        FutureBuilder<List<PopularCityData>>(
          future: const CityRepository().getPopularCities(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            final cities = snapshot.data!;
            return Column(
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
            );
          },
        ),
      ],
    );
  }
}
