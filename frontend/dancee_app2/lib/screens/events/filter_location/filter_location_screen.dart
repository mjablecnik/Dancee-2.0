import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/theme.dart';
import 'sections/all_cities_section.dart';
import 'sections/current_location_section.dart';
import 'sections/filter_location_header_section.dart';
import 'sections/popular_cities_section.dart';

class FilterLocationScreen extends StatefulWidget {
  const FilterLocationScreen({super.key});

  @override
  State<FilterLocationScreen> createState() => _FilterLocationScreenState();
}

class _FilterLocationScreenState extends State<FilterLocationScreen> {
  final TextEditingController _searchController = TextEditingController();

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
          FilterLocationHeaderSection(
            controller: _searchController,
            onBack: () => context.pop(),
          ),
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
                  PopularCitiesSection(onCityTap: (_) {}),
                  const SizedBox(height: AppSpacing.xxxl),
                  AllCitiesSection(onCityTap: (_) {}),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
