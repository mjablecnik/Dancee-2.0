// Feature: firebase-auth
// Task 3.2: Property tests for AuthCubit state transitions
// Properties covered:
//   Property 2: Auth stream events map to correct AuthState
//   Property 3: Auth operations emit loading state first
//   Property 4: Failed auth operations emit error state with message

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dancee_app2/data/repositories/auth_repository.dart';
import 'package:dancee_app2/logic/cubits/auth_cubit.dart';
import 'package:dancee_app2/logic/states/auth_state.dart';

// ---------------------------------------------------------------------------
// Fakes / Helpers
// ---------------------------------------------------------------------------

class _FakeUserMetadata extends Fake implements UserMetadata {
  _FakeUserMetadata({this.creationTime});

  @override
  final DateTime? creationTime;
}

class _FakeUser extends Fake implements User {
  _FakeUser({
    required this.uid,
    this.email,
    this.displayName,
    this.emailVerified = false,
    DateTime? creationTime,
  }) : metadata = _FakeUserMetadata(creationTime: creationTime);

  @override
  final String uid;

  @override
  final String? email;

  @override
  final String? displayName;

  @override
  final bool emailVerified;

  @override
  final UserMetadata metadata;
}

/// Controllable fake [AuthRepository].
///
/// - Push auth state changes via [pushUser].
/// - Configure methods to throw by setting the corresponding flag.
/// - Configure the error message via [errorMessage].
class _FakeAuthRepository extends Fake implements AuthRepository {
  _FakeAuthRepository() : _controller = StreamController<User?>.broadcast();

  final StreamController<User?> _controller;
  User? _currentUser;

  // Throw-on-call flags
  bool throwOnSignInWithEmail = false;
  bool throwOnSignInWithGoogle = false;
  bool throwOnRegister = false;
  bool throwOnSendEmailVerification = false;
  bool throwOnReloadAndCheckVerified = false;
  bool throwOnSendPasswordReset = false;
  bool throwOnSignOut = false;
  bool throwOnReauthenticate = false;
  bool throwOnDeleteAccount = false;

  String errorMessage = 'auth.errors.generic';

  @override
  Stream<User?> get authStateChanges => _controller.stream;

  @override
  User? get currentUser => _currentUser;

  /// Emit a user event on the auth stream.
  void pushUser(User? user) {
    _currentUser = user;
    _controller.add(user);
  }

  void dispose() => _controller.close();

  @override
  Future<UserCredential> signInWithEmail(String email, String password) async {
    if (throwOnSignInWithEmail) throw errorMessage;
    throw UnimplementedError('signInWithEmail — test should not reach here');
  }

  @override
  Future<UserCredential?> signInWithGoogle() async {
    if (throwOnSignInWithGoogle) throw errorMessage;
    throw UnimplementedError('signInWithGoogle — test should not reach here');
  }

  @override
  Future<UserCredential> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    if (throwOnRegister) throw errorMessage;
    throw UnimplementedError('register — test should not reach here');
  }

  @override
  Future<void> sendEmailVerification() async {
    if (throwOnSendEmailVerification) throw errorMessage;
  }

  @override
  Future<bool> reloadAndCheckVerified() async {
    if (throwOnReloadAndCheckVerified) throw errorMessage;
    return _currentUser?.emailVerified ?? false;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    if (throwOnSendPasswordReset) throw errorMessage;
  }

  @override
  Future<void> signOut() async {
    if (throwOnSignOut) throw errorMessage;
  }

  @override
  Future<void> reauthenticate({String? email, String? password}) async {
    if (throwOnReauthenticate) throw errorMessage;
  }

  @override
  Future<void> deleteAccount() async {
    if (throwOnDeleteAccount) throw errorMessage;
  }
}

// ---------------------------------------------------------------------------
// Property 2: Auth stream events map to correct AuthState
// ---------------------------------------------------------------------------

void _propertyAuthStreamMapping() {
  // Requirements: 3.2, 3.3, 3.4
  late _FakeAuthRepository repo;
  late AuthCubit cubit;

  setUp(() {
    repo = _FakeAuthRepository();
    cubit = AuthCubit(authRepository: repo);
  });

  tearDown(() async {
    await cubit.close();
    repo.dispose();
  });

  test('P2a: initial state is unauthenticated before any stream event', () {
    expect(cubit.state, const AuthState.unauthenticated());
  });

  test('P2b: non-null User on stream → authenticated state', () async {
    final user = _FakeUser(
      uid: 'uid-123',
      email: 'alice@example.com',
      displayName: 'Alice',
      emailVerified: true,
    );

    repo.pushUser(user);
    await Future.delayed(Duration.zero);

    cubit.state.maybeMap(
      authenticated: (s) {
        expect(s.uid, equals('uid-123'));
        expect(s.email, equals('alice@example.com'));
        expect(s.displayName, equals('Alice'));
        expect(s.emailVerified, isTrue);
      },
      orElse: () => fail('Expected authenticated state, got ${cubit.state}'),
    );
  });

  test('P2c: null User on stream → unauthenticated state', () async {
    // First authenticate
    final user = _FakeUser(uid: 'uid-123', emailVerified: true);
    repo.pushUser(user);
    await Future.delayed(Duration.zero);

    // Then sign out (null user)
    repo.pushUser(null);
    await Future.delayed(Duration.zero);

    expect(cubit.state, const AuthState.unauthenticated());
  });

  test('P2d: multiple user events emit correct states in sequence', () async {
    final states = <AuthState>[];
    final sub = cubit.stream.listen(states.add);

    final user1 = _FakeUser(uid: 'uid-1', emailVerified: false);
    final user2 = _FakeUser(uid: 'uid-2', emailVerified: true);

    repo.pushUser(user1);
    repo.pushUser(null);
    repo.pushUser(user2);

    await Future.delayed(Duration.zero);

    expect(states.length, equals(3));
    states[0].maybeMap(
      authenticated: (s) => expect(s.uid, equals('uid-1')),
      orElse: () => fail('Expected authenticated, got ${states[0]}'),
    );
    expect(states[1], const AuthState.unauthenticated());
    states[2].maybeMap(
      authenticated: (s) => expect(s.uid, equals('uid-2')),
      orElse: () => fail('Expected authenticated, got ${states[2]}'),
    );

    await sub.cancel();
  });

  test('P2e: unverified email reflected in authenticated state', () async {
    final user = _FakeUser(uid: 'uid-unverified', emailVerified: false);
    repo.pushUser(user);
    await Future.delayed(Duration.zero);

    cubit.state.maybeMap(
      authenticated: (s) => expect(s.emailVerified, isFalse),
      orElse: () => fail('Expected authenticated state'),
    );
  });

  test('P2f: verified email reflected in authenticated state', () async {
    final user = _FakeUser(uid: 'uid-verified', emailVerified: true);
    repo.pushUser(user);
    await Future.delayed(Duration.zero);

    cubit.state.maybeMap(
      authenticated: (s) => expect(s.emailVerified, isTrue),
      orElse: () => fail('Expected authenticated state'),
    );
  });

  test('P2g: null email and displayName are preserved in authenticated state',
      () async {
    final user = _FakeUser(uid: 'uid-no-profile');
    repo.pushUser(user);
    await Future.delayed(Duration.zero);

    cubit.state.maybeMap(
      authenticated: (s) {
        expect(s.email, isNull);
        expect(s.displayName, isNull);
      },
      orElse: () => fail('Expected authenticated state'),
    );
  });
}

// ---------------------------------------------------------------------------
// Property 3: Auth operations emit loading state first
// ---------------------------------------------------------------------------

void _propertyLoadingStateFirst() {
  // Requirements: 3.6
  late _FakeAuthRepository repo;
  late AuthCubit cubit;

  setUp(() {
    repo = _FakeAuthRepository();
    cubit = AuthCubit(authRepository: repo);
  });

  tearDown(() async {
    await cubit.close();
    repo.dispose();
  });

  /// Collects states emitted during [operation] and verifies loading is first.
  Future<void> _assertLoadingFirst(Future<void> Function() operation) async {
    final states = <AuthState>[];
    final sub = cubit.stream.listen(states.add);
    await operation();
    await sub.cancel();

    expect(
      states,
      isNotEmpty,
      reason: 'Operation must emit at least one state',
    );
    expect(
      states.first,
      const AuthState.loading(),
      reason: 'First emitted state must be loading',
    );
  }

  test('P3a: signInWithEmail emits loading first (failure path)', () async {
    repo
      ..throwOnSignInWithEmail = true
      ..errorMessage = 'auth.errors.invalidCredential';
    await _assertLoadingFirst(
        () => cubit.signInWithEmail('a@b.com', 'password'));
  });

  test('P3b: register emits loading first (failure path)', () async {
    repo
      ..throwOnRegister = true
      ..errorMessage = 'auth.errors.emailAlreadyInUse';
    await _assertLoadingFirst(
      () => cubit.register(
        email: 'a@b.com',
        password: 'password',
        firstName: 'A',
        lastName: 'B',
      ),
    );
  });

  test('P3c: sendEmailVerification emits loading first (success path)',
      () async {
    await _assertLoadingFirst(() => cubit.sendEmailVerification());
  });

  test('P3d: sendEmailVerification emits loading first (failure path)',
      () async {
    repo.throwOnSendEmailVerification = true;
    await _assertLoadingFirst(() => cubit.sendEmailVerification());
  });

  test('P3e: reloadUser emits loading first (success path)', () async {
    await _assertLoadingFirst(() => cubit.reloadUser());
  });

  test('P3f: sendPasswordReset emits loading first (success path)', () async {
    await _assertLoadingFirst(() => cubit.sendPasswordReset('a@b.com'));
  });

  test('P3g: sendPasswordReset emits loading first (failure path)', () async {
    repo.throwOnSendPasswordReset = true;
    await _assertLoadingFirst(() => cubit.sendPasswordReset('a@b.com'));
  });

  test('P3h: signOut emits loading first (success path)', () async {
    await _assertLoadingFirst(() => cubit.signOut());
  });

  test('P3i: signOut emits loading first (failure path)', () async {
    repo.throwOnSignOut = true;
    await _assertLoadingFirst(() => cubit.signOut());
  });

  test('P3j: deleteAccount emits loading first (failure path)', () async {
    repo.throwOnReauthenticate = true;
    await _assertLoadingFirst(
        () => cubit.deleteAccount(email: 'a@b.com', password: 'pass'));
  });
}

// ---------------------------------------------------------------------------
// Property 4: Failed auth operations emit error state with non-empty message
// ---------------------------------------------------------------------------

void _propertyFailedOperationsEmitError() {
  // Requirements: 3.7
  late _FakeAuthRepository repo;
  late AuthCubit cubit;

  setUp(() {
    repo = _FakeAuthRepository();
    cubit = AuthCubit(authRepository: repo);
  });

  tearDown(() async {
    await cubit.close();
    repo.dispose();
  });

  void _assertErrorStateNonEmpty() {
    cubit.state.maybeMap(
      error: (e) {
        expect(
          e.message,
          isNotEmpty,
          reason: 'Error message must be non-empty',
        );
      },
      orElse: () => fail('Expected error state, got ${cubit.state}'),
    );
  }

  test('P4a: signInWithEmail failure → error state with non-empty message',
      () async {
    repo
      ..throwOnSignInWithEmail = true
      ..errorMessage = 'auth.errors.invalidCredential';
    await cubit.signInWithEmail('a@b.com', 'wrong');
    _assertErrorStateNonEmpty();
  });

  test('P4b: register failure → error state with non-empty message', () async {
    repo
      ..throwOnRegister = true
      ..errorMessage = 'auth.errors.emailAlreadyInUse';
    await cubit.register(
      email: 'a@b.com',
      password: 'password',
      firstName: 'A',
      lastName: 'B',
    );
    _assertErrorStateNonEmpty();
  });

  test('P4c: sendEmailVerification failure → error state with non-empty message',
      () async {
    repo
      ..throwOnSendEmailVerification = true
      ..errorMessage = 'auth.errors.generic';
    await cubit.sendEmailVerification();
    _assertErrorStateNonEmpty();
  });

  test('P4d: reloadUser failure → error state with non-empty message',
      () async {
    repo
      ..throwOnReloadAndCheckVerified = true
      ..errorMessage = 'auth.errors.networkError';
    await cubit.reloadUser();
    _assertErrorStateNonEmpty();
  });

  test('P4e: sendPasswordReset failure → error state with non-empty message',
      () async {
    repo
      ..throwOnSendPasswordReset = true
      ..errorMessage = 'auth.errors.tooManyRequests';
    await cubit.sendPasswordReset('a@b.com');
    _assertErrorStateNonEmpty();
  });

  test('P4f: signOut failure → error state with non-empty message', () async {
    repo
      ..throwOnSignOut = true
      ..errorMessage = 'auth.errors.generic';
    await cubit.signOut();
    _assertErrorStateNonEmpty();
  });

  test('P4g: deleteAccount re-auth failure → error state with non-empty message',
      () async {
    repo
      ..throwOnReauthenticate = true
      ..errorMessage = 'auth.errors.invalidCredential';
    await cubit.deleteAccount(email: 'a@b.com', password: 'wrong');
    _assertErrorStateNonEmpty();
  });

  test('P4h: error message matches thrown exception string', () async {
    const expectedMessage = 'auth.errors.weakPassword';
    repo
      ..throwOnRegister = true
      ..errorMessage = expectedMessage;
    await cubit.register(
      email: 'a@b.com',
      password: '123',
      firstName: 'A',
      lastName: 'B',
    );

    cubit.state.maybeMap(
      error: (e) => expect(e.message, equals(expectedMessage)),
      orElse: () => fail('Expected error state'),
    );
  });

  test(
      'P4i: every known error code produces a distinct, non-empty error message',
      () async {
    final errorCodes = [
      'auth.errors.invalidCredential',
      'auth.errors.userDisabled',
      'auth.errors.emailAlreadyInUse',
      'auth.errors.weakPassword',
      'auth.errors.tooManyRequests',
      'auth.errors.networkError',
      'auth.errors.generic',
    ];

    for (final code in errorCodes) {
      final testRepo = _FakeAuthRepository()
        ..throwOnSendPasswordReset = true
        ..errorMessage = code;
      final testCubit = AuthCubit(authRepository: testRepo);

      await testCubit.sendPasswordReset('a@b.com');

      testCubit.state.maybeMap(
        error: (e) => expect(e.message, isNotEmpty,
            reason: 'Error state for code "$code" must have non-empty message'),
        orElse: () => fail('Expected error state for code "$code"'),
      );

      await testCubit.close();
      testRepo.dispose();
    }
  });
}

// ---------------------------------------------------------------------------
// Test entry point
// ---------------------------------------------------------------------------

void main() {
  group('AuthCubit — property tests', () {
    group(
      'Property 2: Auth stream events map to correct AuthState',
      _propertyAuthStreamMapping,
    );
    group(
      'Property 3: Auth operations emit loading state first',
      _propertyLoadingStateFirst,
    );
    group(
      'Property 4: Failed auth operations emit error state with message',
      _propertyFailedOperationsEmitError,
    );
  });
}
