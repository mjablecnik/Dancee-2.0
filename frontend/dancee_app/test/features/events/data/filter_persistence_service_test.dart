import 'package:dancee_app/features/events/data/filter_persistence_service.dart';
import 'package:dancee_app/features/events/logic/event_filter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('FilterPersistenceService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('save and load round trip preserves FilterState', () async {
      final service = FilterPersistenceService();
      final original = FilterState(
        searchQuery: 'salsa',
        selectedDanceTypes: {'Salsa', 'Bachata'},
        selectedRegions: {'Prague', 'Brno'},
        dateFrom: DateTime(2026, 5, 1),
        dateTo: DateTime(2026, 5, 31),
      );

      await service.saveFilters(original);
      final loaded = await service.loadFilters();

      expect(loaded, isNotNull);
      expect(loaded!.searchQuery, equals(original.searchQuery));
      expect(loaded.selectedDanceTypes, equals(original.selectedDanceTypes));
      expect(loaded.selectedRegions, equals(original.selectedRegions));
      expect(loaded.dateFrom, equals(original.dateFrom));
      expect(loaded.dateTo, equals(original.dateTo));
    });

    test('loadFilters returns null when nothing saved', () async {
      final service = FilterPersistenceService();
      final result = await service.loadFilters();
      expect(result, isNull);
    });

    test('loadFilters returns null for corrupt JSON', () async {
      SharedPreferences.setMockInitialValues({
        'saved_event_filters': '{not valid json:::',
      });
      final service = FilterPersistenceService();
      final result = await service.loadFilters();
      expect(result, isNull);
    });

    test('clearFilters removes saved filters so next load returns null',
        () async {
      final service = FilterPersistenceService();
      await service.saveFilters(const FilterState(searchQuery: 'tango'));

      // Verify saved
      expect(await service.loadFilters(), isNotNull);

      await service.clearFilters();

      expect(await service.loadFilters(), isNull);
    });

    test('save overwrites previous filters', () async {
      final service = FilterPersistenceService();
      await service.saveFilters(const FilterState(searchQuery: 'first'));
      await service.saveFilters(const FilterState(searchQuery: 'second'));

      final loaded = await service.loadFilters();
      expect(loaded!.searchQuery, equals('second'));
    });
  });
}
