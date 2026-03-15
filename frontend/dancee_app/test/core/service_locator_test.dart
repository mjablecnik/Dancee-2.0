import 'package:flutter_test/flutter_test.dart';
import 'package:dancee_app/core/service_locator.dart';
import 'package:dancee_app/core/clients.dart';
import 'package:dancee_app/features/events/data/event_repository.dart';
import 'package:dancee_app/features/auth/data/auth_repository.dart';
import 'package:dancee_app/features/settings/data/settings_repository.dart';
import 'package:dancee_app/features/events/logic/event_list.dart';
import 'package:dancee_app/features/events/logic/favorites.dart';
import 'package:dancee_app/features/auth/logic/auth.dart';
import 'package:dancee_app/features/settings/logic/settings.dart';

void main() {
  group('Service Locator Tests', () {
    setUp(() {
      getIt.reset();
      setupDependencies();
    });

    tearDown(() {
      getIt.reset();
    });

    test('ApiClient returns same instance on multiple calls', () {
      final instance1 = getIt<ApiClient>();
      final instance2 = getIt<ApiClient>();

      expect(identical(instance1, instance2), isTrue,
          reason: 'ApiClient should return the same instance (lazy singleton)');
    });

    test('EventRepository returns same instance on multiple calls', () {
      final instance1 = getIt<EventRepository>();
      final instance2 = getIt<EventRepository>();

      expect(identical(instance1, instance2), isTrue,
          reason: 'EventRepository should return the same instance (lazy singleton)');
    });

    test('AuthRepository returns same instance on multiple calls', () {
      final instance1 = getIt<AuthRepository>();
      final instance2 = getIt<AuthRepository>();

      expect(identical(instance1, instance2), isTrue,
          reason: 'AuthRepository should return the same instance (lazy singleton)');
    });

    test('SettingsRepository returns same instance on multiple calls', () {
      final instance1 = getIt<SettingsRepository>();
      final instance2 = getIt<SettingsRepository>();

      expect(identical(instance1, instance2), isTrue,
          reason: 'SettingsRepository should return the same instance (lazy singleton)');
    });

    test('EventListCubit returns new instance on each call', () {
      final instance1 = getIt<EventListCubit>();
      final instance2 = getIt<EventListCubit>();

      expect(identical(instance1, instance2), isFalse,
          reason: 'EventListCubit should return a new instance (factory)');
    });

    test('FavoritesCubit returns new instance on each call', () {
      final instance1 = getIt<FavoritesCubit>();
      final instance2 = getIt<FavoritesCubit>();

      expect(identical(instance1, instance2), isFalse,
          reason: 'FavoritesCubit should return a new instance (factory)');
    });

    test('AuthCubit returns new instance on each call', () {
      final instance1 = getIt<AuthCubit>();
      final instance2 = getIt<AuthCubit>();

      expect(identical(instance1, instance2), isFalse,
          reason: 'AuthCubit should return a new instance (factory)');
    });

    test('SettingsCubit returns new instance on each call', () {
      final instance1 = getIt<SettingsCubit>();
      final instance2 = getIt<SettingsCubit>();

      expect(identical(instance1, instance2), isFalse,
          reason: 'SettingsCubit should return a new instance (factory)');
    });

    test('All dependencies are registered correctly', () {
      expect(() => getIt<ApiClient>(), returnsNormally);
      expect(() => getIt<EventRepository>(), returnsNormally);
      expect(() => getIt<AuthRepository>(), returnsNormally);
      expect(() => getIt<SettingsRepository>(), returnsNormally);
      expect(() => getIt<EventListCubit>(), returnsNormally);
      expect(() => getIt<FavoritesCubit>(), returnsNormally);
      expect(() => getIt<AuthCubit>(), returnsNormally);
      expect(() => getIt<SettingsCubit>(), returnsNormally);
    });
  });
}
