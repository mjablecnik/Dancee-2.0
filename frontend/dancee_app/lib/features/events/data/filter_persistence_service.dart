import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../logic/event_filter.dart';

/// Handles optional persistence of [FilterState] via SharedPreferences.
///
/// Filters are only persisted when the user explicitly calls [saveFilters].
/// On deserialization failure, [loadFilters] returns `null` so the caller
/// can fall back to the default empty state.
class FilterPersistenceService {
  static const _key = 'saved_event_filters';

  /// Loads the previously saved [FilterState] from SharedPreferences.
  ///
  /// Returns `null` if no filters are saved or if the stored JSON is corrupt.
  Future<FilterState?> loadFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);
      if (jsonString == null) return null;
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return FilterState.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// Serializes [filters] to JSON and writes it to SharedPreferences.
  Future<void> saveFilters(FilterState filters) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(filters.toJson());
    await prefs.setString(_key, jsonString);
  }

  /// Removes the saved filters from SharedPreferences.
  Future<void> clearFilters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
