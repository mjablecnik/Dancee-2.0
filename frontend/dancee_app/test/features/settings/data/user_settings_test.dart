import 'package:dancee_app/features/settings/data/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserSettings', () {
    // =========================================================================
    // TC-026: fromJson / toJson round-trip is lossless
    // =========================================================================

    test('TC-026: fromJson/toJson round-trip is lossless', () {
      final json = {
        'id': 'settings-1',
        'userId': 'user-123',
        'language': 'cs',
        'themeMode': 'dark',
        'notificationsEnabled': false,
        'emailNotificationsEnabled': true,
      };

      final settings = UserSettings.fromJson(json);

      expect(settings.id, equals('settings-1'));
      expect(settings.userId, equals('user-123'));
      expect(settings.language, equals('cs'));
      expect(settings.themeMode, equals('dark'));
      expect(settings.notificationsEnabled, isFalse);
      expect(settings.emailNotificationsEnabled, isTrue);

      final roundTripped = UserSettings.fromJson(settings.toJson());
      expect(roundTripped, equals(settings));
    });

    // =========================================================================
    // TC-027: Default values are applied for missing JSON keys
    // =========================================================================

    test('TC-027: missing optional fields resolve to documented defaults', () {
      final minimalJson = {
        'id': 'settings-2',
        'userId': 'user-456',
        // language, themeMode, notifications omitted
      };

      final settings = UserSettings.fromJson(minimalJson);

      expect(settings.language, equals('en'));
      expect(settings.themeMode, equals('system'));
      expect(settings.notificationsEnabled, isTrue);
      expect(settings.emailNotificationsEnabled, isTrue);
    });
  });
}
