import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../core/colors.dart';

// ─── Model classes ───────────────────────────────────────────────────────────

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

class CityData {
  final String name;
  final String count;

  const CityData({required this.name, required this.count});
}

// ─── Repository ───────────────────────────────────────────────────────────────

class CityRepository {
  const CityRepository();

  Future<List<PopularCityData>> getPopularCities() async {
    return const [
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
  }

  Future<List<CityData>> getAllCities() async {
    return const [
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
  }
}
