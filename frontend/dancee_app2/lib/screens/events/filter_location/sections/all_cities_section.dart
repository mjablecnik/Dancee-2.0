import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';
import '../../../../data/city_repository.dart';
import '../../../../i18n/strings.g.dart';

class AllCitiesSection extends StatelessWidget {
  final ValueChanged<CityData>? onCityTap;

  const AllCitiesSection({
    super.key,
    this.onCityTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.events.filter.allCities,
          style: const TextStyle(
            fontSize: AppTypography.fontSize2xl,
            fontWeight: FontWeight.bold,
            color: appText,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        FutureBuilder<List<CityData>>(
          future: const CityRepository().getAllCities(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            final cities = snapshot.data!;
            return Column(
              children: cities
                  .map((city) => _CityRow(city: city, onTap: () => onCityTap?.call(city)))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _CityRow extends StatelessWidget {
  final CityData city;
  final VoidCallback? onTap;

  const _CityRow({required this.city, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
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
}
