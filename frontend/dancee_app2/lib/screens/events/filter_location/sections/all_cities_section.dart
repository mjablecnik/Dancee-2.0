import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/theme.dart';

class CityData {
  final String name;
  final String count;

  const CityData({required this.name, required this.count});
}

const _defaultCities = [
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

class AllCitiesSection extends StatelessWidget {
  final List<CityData> cities;
  final ValueChanged<CityData>? onCityTap;

  const AllCitiesSection({
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
          'Všechna města',
          style: TextStyle(
            fontSize: AppTypography.fontSize2xl,
            fontWeight: FontWeight.bold,
            color: appText,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Column(
          children: cities
              .map((city) => _CityRow(city: city, onTap: () => onCityTap?.call(city)))
              .toList(),
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
