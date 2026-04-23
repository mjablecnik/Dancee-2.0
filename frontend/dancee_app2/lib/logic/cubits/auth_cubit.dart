import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../data/repositories/auth_repository.dart';
import '../states/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState.unauthenticated()) {
    _authStateSubscription = authRepository.authStateChanges.listen(
      _onAuthStateChanged,
    );
  }

  final AuthRepository _authRepository;
  late final StreamSubscription<User?> _authStateSubscription;

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    return super.close();
  }

  void _onAuthStateChanged(User? user) {
    if (user == null) {
      emit(const AuthState.unauthenticated());
    } else {
      emit(AuthState.authenticated(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        emailVerified: user.emailVerified,
        isNewUser: _checkIsNewUser(user),
      ));
    }
  }

  bool _checkIsNewUser(User user) {
    final creationTime = user.metadata.creationTime;
    if (creationTime == null) return false;
    final diff = DateTime.now().difference(creationTime).abs();
    return diff.inSeconds <= 60;
  }

  String? get currentUid => state.maybeMap(
        authenticated: (s) => s.uid,
        orElse: () => null,
      );

  Future<void> signInWithEmail(String email, String password) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.signInWithEmail(email, password);
      // authStateChanges stream will emit the authenticated state
    } catch (e) {
      emit(AuthState.error(message: e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    final previousState = state;
    emit(const AuthState.loading());
    try {
      final credential = await _authRepository.signInWithGoogle();
      if (credential == null) {
        // User cancelled — restore previous state
        emit(previousState);
        return;
      }
      // authStateChanges stream will emit the authenticated state
    } catch (e) {
      emit(AuthState.error(message: e.toString()));
    }
  }

  Future<void> signInWithApple() async {
    final previousState = state;
    emit(const AuthState.loading());
    try {
      await _authRepository.signInWithApple();
      // authStateChanges stream will emit the authenticated state
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        emit(previousState);
      } else {
        emit(AuthState.error(message: e.message));
      }
    } catch (e) {
      emit(AuthState.error(message: e.toString()));
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      // authStateChanges stream will emit the authenticated state
    } catch (e) {
      emit(AuthState.error(message: e.toString()));
    }
  }

  Future<void> sendEmailVerification() async {
    emit(const AuthState.loading());
    try {
      await _authRepository.sendEmailVerification();
      _onAuthStateChanged(_authRepository.currentUser);
    } catch (e) {
      emit(AuthState.error(message: e.toString()));
    }
  }

  Future<void> reloadUser() async {
    emit(const AuthState.loading());
    try {
      await _authRepository.reloadAndCheckVerified();
      _onAuthStateChanged(_authRepository.currentUser);
    } catch (e) {
      emit(AuthState.error(message: e.toString()));
    }
  }

  Future<void> sendPasswordReset(String email) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.sendPasswordReset(email);
      _onAuthStateChanged(_authRepository.currentUser);
    } catch (e) {
      emit(AuthState.error(message: e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(const AuthState.loading());
    try {
      await _authRepository.signOut();
      // authStateChanges stream will emit unauthenticated
    } catch (e) {
      emit(AuthState.error(message: e.toString()));
    }
  }

  Future<void> deleteAccount({String? email, String? password}) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.reauthenticate(email: email, password: password);
      await _authRepository.deleteAccount();
      // authStateChanges stream will emit unauthenticated
    } catch (e) {
      emit(AuthState.error(message: e.toString()));
    }
  }
}
