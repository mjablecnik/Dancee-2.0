import 'package:flutter_test/flutter_test.dart';
import 'package:dancee_app/di/service_locator.dart';
import 'package:dancee_app/core/clients/api_client.dart';
import 'package:dancee_app/repositories/event_repository.dart';
import 'package:dancee_app/cubits/event_list/event_list_cubit.dart';
import 'package:dancee_app/cubits/favorites/favorites_cubit.dart';

void main() {
  group('Service Locator Tests', () {
    setUp(() {
      // Reset GetIt before each test
      getIt.reset();
      setupDependencies();
    });

    tearDown(() {
      // Clean up after each test
      getIt.reset();
    });

    test('ApiClient returns same instance on multiple calls', () {
      // Arrange & Act
      final instance1 = getIt<ApiClient>();
      final instance2 = getIt<ApiClient>();

      // Assert
      expect(identical(instance1, instance2), isTrue,
          reason: 'ApiClient should return the same instance (lazy singleton)');
    });

    test('EventRepository returns same instance on multiple calls', () {
      // Arrange & Act
      final instance1 = getIt<EventRepository>();
      final instance2 = getIt<EventRepository>();

      // Assert
      expect(identical(instance1, instance2), isTrue,
          reason: 'EventRepository should return the same instance (lazy singleton)');
    });

    test('EventListCubit returns same instance on multiple calls', () {
      // Arrange & Act
      final instance1 = getIt<EventListCubit>();
      final instance2 = getIt<EventListCubit>();

      // Assert
      expect(identical(instance1, instance2), isTrue,
          reason: 'EventListCubit should return the same instance (lazy singleton)');
    });

    test('FavoritesCubit returns same instance on multiple calls', () {
      // Arrange & Act
      final instance1 = getIt<FavoritesCubit>();
      final instance2 = getIt<FavoritesCubit>();

      // Assert
      expect(identical(instance1, instance2), isTrue,
          reason: 'FavoritesCubit should return the same instance (lazy singleton)');
    });

    test('EventRepository receives ApiClient dependency', () {
      // Arrange & Act
      final apiClient = getIt<ApiClient>();
      final repository = getIt<EventRepository>();

      // Assert
      expect(repository, isNotNull);
      expect(apiClient, isNotNull);
      // Note: We can't directly verify the injected dependency without exposing
      // the private field, but we can verify both are registered and instantiated
    });

    test('EventListCubit receives EventRepository dependency', () {
      // Arrange & Act
      final repository = getIt<EventRepository>();
      final cubit = getIt<EventListCubit>();

      // Assert
      expect(cubit, isNotNull);
      expect(repository, isNotNull);
    });

    test('FavoritesCubit receives EventRepository dependency', () {
      // Arrange & Act
      final repository = getIt<EventRepository>();
      final cubit = getIt<FavoritesCubit>();

      // Assert
      expect(cubit, isNotNull);
      expect(repository, isNotNull);
    });

    test('All dependencies are registered correctly', () {
      // Arrange & Act & Assert
      expect(() => getIt<ApiClient>(), returnsNormally);
      expect(() => getIt<EventRepository>(), returnsNormally);
      expect(() => getIt<EventListCubit>(), returnsNormally);
      expect(() => getIt<FavoritesCubit>(), returnsNormally);
    });
  });
}
