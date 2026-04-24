// Feature: firebase-auth
// Task 2.5: Property test for error code mapping
// Properties covered:
//   Property 1: Error code mapping always returns a non-empty string

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:dancee_app2/data/repositories/auth_repository.dart';
import 'package:dancee_app2/i18n/strings.g.dart';

class _FakeFirebaseAuth extends Fake implements FirebaseAuth {}

class _FakeGoogleSignIn extends Fake implements GoogleSignIn {}

// ---------------------------------------------------------------------------
// Property 1: Error code mapping always returns a non-empty string
// ---------------------------------------------------------------------------

void _propertyErrorCodeMapping() {
  // Requirements: 2.10, 14.1, 14.2, 14.3, 14.4, 14.5, 14.6, 14.7
  late AuthRepository repository;

  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.en);
  });

  setUp(() {
    repository = AuthRepository(
      firebaseAuth: _FakeFirebaseAuth(),
      googleSignIn: _FakeGoogleSignIn(),
    );
  });

  FirebaseAuthException _makeException(String code) =>
      FirebaseAuthException(code: code);

  test('P1a: known error codes map to their distinct, non-empty translated strings', () {
    final knownMappings = {
      'invalid-credential': 'Invalid email or password',
      'user-disabled': 'This account has been disabled',
      'email-already-in-use': 'An account with this email already exists',
      'weak-password': 'Password is too weak',
      'too-many-requests': 'Too many attempts. Please try again later',
      'network-request-failed': 'Network error. Please check your connection',
    };

    for (final entry in knownMappings.entries) {
      final result = repository.mapFirebaseError(_makeException(entry.key));
      expect(
        result,
        equals(entry.value),
        reason: 'Code "${entry.key}" should map to "${entry.value}"',
      );
    }
  });

  test('P1b: known codes produce distinct translated strings', () {
    final knownCodes = [
      'invalid-credential',
      'user-disabled',
      'email-already-in-use',
      'weak-password',
      'too-many-requests',
      'network-request-failed',
    ];

    final results = knownCodes.map((code) {
      return repository.mapFirebaseError(_makeException(code));
    }).toList();

    // All results should be unique (distinct strings)
    expect(results.toSet().length, equals(results.length),
        reason: 'Each known error code should map to a distinct translated string');
  });

  test('P1c: unknown error codes fall back to the generic translated string', () {
    const unknownCodes = [
      'some-unknown-code',
      'random-error',
      '',
      'INVALID-CREDENTIAL', // wrong case
      'network_request_failed', // wrong separator
      'user_disabled',
    ];

    const expectedGeneric = 'An error occurred. Please try again';
    for (final code in unknownCodes) {
      final result = repository.mapFirebaseError(_makeException(code));
      expect(
        result,
        equals(expectedGeneric),
        reason: 'Unknown code "$code" should fall back to the generic error string',
      );
    }
  });

  test('P1d: every error code (known or unknown) returns a non-null, non-empty string', () {
    final allCodes = [
      'invalid-credential',
      'user-disabled',
      'email-already-in-use',
      'weak-password',
      'too-many-requests',
      'network-request-failed',
      'some-unknown-code',
      '',
      'random-error-xyz',
    ];

    for (final code in allCodes) {
      final result = repository.mapFirebaseError(_makeException(code));
      expect(result, isNotNull,
          reason: 'mapFirebaseError("$code") must not return null');
      expect(result, isNotEmpty,
          reason: 'mapFirebaseError("$code") must not return an empty string');
    }
  });

  test('P1e: all returned strings are non-empty (translated directly, no longer key prefixed)', () {
    final allCodes = [
      'invalid-credential',
      'user-disabled',
      'email-already-in-use',
      'weak-password',
      'too-many-requests',
      'network-request-failed',
      'unknown-code',
      '',
    ];

    for (final code in allCodes) {
      final result = repository.mapFirebaseError(_makeException(code));
      expect(
        result,
        isNotEmpty,
        reason: 'Translated string for "$code" should not be empty',
      );
    }
  });
}

// ---------------------------------------------------------------------------
// Test entry point
// ---------------------------------------------------------------------------

void main() {
  group('AuthRepository — property tests', () {
    group('Property 1: Error code mapping always returns a non-empty string',
        _propertyErrorCodeMapping);
  });
}
