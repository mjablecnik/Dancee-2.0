import 'package:dancee_app/features/auth/data/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('User', () {
    // =========================================================================
    // TC-024: fromJson / toJson round-trip is lossless
    // =========================================================================

    test('TC-024: fromJson/toJson round-trip is lossless', () {
      final json = {
        'id': 'user-123',
        'email': 'alice@example.com',
        'displayName': 'Alice',
        'photoUrl': 'https://example.com/photo.jpg',
      };

      final user = User.fromJson(json);

      expect(user.id, equals('user-123'));
      expect(user.email, equals('alice@example.com'));
      expect(user.displayName, equals('Alice'));
      expect(user.photoUrl, equals('https://example.com/photo.jpg'));

      final roundTripped = User.fromJson(user.toJson());
      expect(roundTripped, equals(user));
    });

    test('TC-024: fromJson/toJson round-trip with null photoUrl', () {
      final json = {
        'id': 'user-456',
        'email': 'bob@example.com',
        'displayName': 'Bob',
        'photoUrl': null,
      };

      final user = User.fromJson(json);
      expect(user.photoUrl, isNull);

      final roundTripped = User.fromJson(user.toJson());
      expect(roundTripped, equals(user));
    });
  });
}
