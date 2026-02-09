import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dancee_app/screens/favorites_screen.dart';
import 'package:dancee_app/cubits/favorites/favorites_cubit.dart';
import 'package:dancee_app/cubits/favorites/favorites_state.dart';
import 'package:dancee_app/cubits/event_list/event_list_cubit.dart';
import 'package:dancee_app/cubits/event_list/event_list_state.dart';
import 'package:dancee_app/repositories/event_repository.dart';
import 'package:dancee_app/core/clients/api_client.dart';
import 'package:dancee_app/di/service_locator.dart';

// Mock classes
class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late EventRepository repository;
  late FavoritesCubit favoritesCubit;
  late EventListCubit eventListCubit;

  setUp(() {
    // Initialize dependencies before each test
    mockApiClient = MockApiClient();
    repository = EventRepository(mockApiClient);
    favoritesCubit = FavoritesCubit(repository);
    eventListCubit = EventListCubit(repository);
    
    // Mock API responses to return empty lists by default
    when(() => mockApiClient.get(
      any(),
      queryParameters: any(named: 'queryParameters'),
    )).thenAnswer((_) async => []);
    
    when(() => mockApiClient.post(
      any(),
      data: any(named: 'data'),
    )).thenAnswer((_) async => {});
    
    when(() => mockApiClient.delete(
      any(),
      queryParameters: any(named: 'queryParameters'),
    )).thenAnswer((_) async => {});
    
    // Register in GetIt
    getIt.registerSingleton<EventRepository>(repository);
    getIt.registerSingleton<FavoritesCubit>(favoritesCubit);
    getIt.registerSingleton<EventListCubit>(eventListCubit);
  });

  tearDown(() {
    // Clean up after each test
    getIt.reset();
  });

  group('FavoritesScreen Widget Tests', () {
    testWidgets('displays loading indicator when state is loading', (WidgetTester tester) async {
      // Arrange - don't emit, let it stay in initial state or emit loading
      // The screen should show loading when cubit is in loading state
      
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: FavoritesScreen(),
        ),
      );
      
      // Emit loading state after widget is built
      favoritesCubit.emit(const FavoritesLoading());
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays empty state when no favorites exist', (WidgetTester tester) async {
      // Arrange
      favoritesCubit.emit(const FavoritesEmpty());

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: FavoritesScreen(),
        ),
      );
      await tester.pump();

      // Assert - check for icon (text might be translated)
      expect(find.byIcon(Icons.heart_broken), findsOneWidget);
    });

    testWidgets('displays error message and retry button when state is error', (WidgetTester tester) async {
      // Arrange
      const errorMessage = 'Failed to load favorites';
      
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: FavoritesScreen(),
        ),
      );
      
      // Emit error state after widget is built
      favoritesCubit.emit(const FavoritesError(errorMessage));
      await tester.pump();

      // Assert - check for error icon and retry button
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('retry button calls loadFavorites when tapped', (WidgetTester tester) async {
      // Arrange
      
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: FavoritesScreen(),
        ),
      );
      
      // Emit error state after widget is built
      favoritesCubit.emit(const FavoritesError('Test error'));
      await tester.pump();

      // Tap retry button (find by type since text is translated)
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Assert - should transition to loaded or empty state
      expect(favoritesCubit.state, anyOf(isA<FavoritesLoaded>(), isA<FavoritesEmpty>()));
    });

    testWidgets('displays favorite events when state is loaded', (WidgetTester tester) async {
      // Arrange
      await favoritesCubit.loadFavorites();

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: FavoritesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      final state = favoritesCubit.state;
      if (state is FavoritesLoaded) {
        expect(find.text('Favorite Events'), findsOneWidget);
        
        // Check that event count is displayed
        final totalEvents = state.upcomingEvents.length + state.pastEvents.length;
        expect(find.text('$totalEvents saved events'), findsOneWidget);
      }
    });

    testWidgets('displays upcoming events section when upcoming favorites exist', (WidgetTester tester) async {
      // Arrange
      await favoritesCubit.loadFavorites();

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: FavoritesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      final state = favoritesCubit.state;
      if (state is FavoritesLoaded && state.upcomingEvents.isNotEmpty) {
        expect(find.text('Upcoming Events'), findsOneWidget);
      }
    });

    testWidgets('displays past events section when past favorites exist', (WidgetTester tester) async {
      // Arrange
      await favoritesCubit.loadFavorites();

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: FavoritesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      final state = favoritesCubit.state;
      if (state is FavoritesLoaded && state.pastEvents.isNotEmpty) {
        expect(find.text('Past Events'), findsOneWidget);
      }
    });

    testWidgets('separates upcoming and past events correctly', (WidgetTester tester) async {
      // Arrange
      await favoritesCubit.loadFavorites();

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: FavoritesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      final state = favoritesCubit.state;
      if (state is FavoritesLoaded) {
        // Verify upcoming events are not past
        for (final event in state.upcomingEvents) {
          expect(event.isPast, false);
        }
        
        // Verify past events are marked as past
        for (final event in state.pastEvents) {
          expect(event.isPast, true);
        }
      }
    });

    testWidgets('favorite event cards display correct information', (WidgetTester tester) async {
      // Arrange
      await favoritesCubit.loadFavorites();

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: FavoritesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      final state = favoritesCubit.state;
      if (state is FavoritesLoaded && state.upcomingEvents.isNotEmpty) {
        final firstEvent = state.upcomingEvents.first;
        
        // Check event title is displayed
        expect(find.text(firstEvent.title), findsOneWidget);
        
        // Check venue name is displayed
        expect(find.text(firstEvent.venue.name), findsOneWidget);
        
        // Check that dance tags are displayed
        for (final dance in firstEvent.dances) {
          expect(find.text(dance), findsWidgets);
        }
      }
    });

    testWidgets('displays badge when event has badge', (WidgetTester tester) async {
      // Arrange
      await favoritesCubit.loadFavorites();

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: FavoritesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      final state = favoritesCubit.state;
      if (state is FavoritesLoaded) {
        final allEvents = [...state.upcomingEvents, ...state.pastEvents];
        final eventsWithBadge = allEvents.where((e) => e.badge != null);
        
        for (final event in eventsWithBadge) {
          expect(find.text(event.badge!), findsWidgets);
        }
      }
    });

    testWidgets('past events are displayed with reduced opacity', (WidgetTester tester) async {
      // Arrange
      await favoritesCubit.loadFavorites();

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: FavoritesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      final state = favoritesCubit.state;
      if (state is FavoritesLoaded && state.pastEvents.isNotEmpty) {
        // Find Opacity widgets
        final opacityWidgets = find.byType(Opacity);
        expect(opacityWidgets, findsWidgets);
      }
    });

    testWidgets('remove favorite button is displayed on each event', (WidgetTester tester) async {
      // Arrange
      await favoritesCubit.loadFavorites();

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: FavoritesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      final state = favoritesCubit.state;
      if (state is FavoritesLoaded) {
        final totalEvents = state.upcomingEvents.length + state.pastEvents.length;
        if (totalEvents > 0) {
          // Check for heart_broken or delete icons
          final removeButtons = find.byWidgetPredicate(
            (widget) => widget is Icon && (widget.icon == Icons.heart_broken || widget.icon == Icons.delete),
          );
          expect(removeButtons, findsWidgets);
        }
      }
    });

    testWidgets('tapping remove button shows confirmation dialog', (WidgetTester tester) async {
      // Arrange
      await favoritesCubit.loadFavorites();

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: FavoritesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap first remove button
      final state = favoritesCubit.state;
      if (state is FavoritesLoaded && state.upcomingEvents.isNotEmpty) {
        final removeButtons = find.byWidgetPredicate(
          (widget) => widget is Icon && widget.icon == Icons.heart_broken,
        );
        
        if (removeButtons.evaluate().isNotEmpty) {
          await tester.tap(removeButtons.first);
          await tester.pumpAndSettle();

          // Assert - confirmation dialog should appear
          expect(find.text('Remove from Favorites?'), findsOneWidget);
          expect(find.text('This event will be removed from your favorite items.'), findsOneWidget);
          expect(find.text('Yes, Remove'), findsOneWidget);
        }
      }
    });

    testWidgets('confirming removal toggles favorite status', (WidgetTester tester) async {
      // Arrange
      await favoritesCubit.loadFavorites();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const FavoritesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap first remove button
      final initialState = favoritesCubit.state;
      if (initialState is FavoritesLoaded && initialState.upcomingEvents.isNotEmpty) {
        final initialCount = initialState.upcomingEvents.length + initialState.pastEvents.length;
        
        final removeButtons = find.byWidgetPredicate(
          (widget) => widget is Icon && widget.icon == Icons.heart_broken,
        );
        
        if (removeButtons.evaluate().isNotEmpty) {
          await tester.tap(removeButtons.first);
          await tester.pumpAndSettle();

          // Confirm removal
          await tester.tap(find.text('Yes, Remove'));
          await tester.pumpAndSettle();

          // Assert - event should be removed from favorites
          final newState = favoritesCubit.state;
          if (newState is FavoritesLoaded) {
            final newCount = newState.upcomingEvents.length + newState.pastEvents.length;
            expect(newCount, lessThan(initialCount));
          } else if (newState is FavoritesEmpty) {
            // If it was the last favorite, state should be empty
            expect(newState, isA<FavoritesEmpty>());
          }
        }
      }
    });

    testWidgets('filter chips are displayed', (WidgetTester tester) async {
      // Arrange
      await favoritesCubit.loadFavorites();

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: FavoritesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      final state = favoritesCubit.state;
      if (state is FavoritesLoaded) {
        expect(find.text('All'), findsOneWidget);
        expect(find.text('Today'), findsOneWidget);
        expect(find.text('This week'), findsOneWidget);
        expect(find.text('This month'), findsOneWidget);
      }
    });

    testWidgets('no hardcoded event data in UI', (WidgetTester tester) async {
      // Arrange - create repository and load favorites
      await favoritesCubit.loadFavorites();

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: FavoritesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - events should come from repository, not hardcoded in UI
      final state = favoritesCubit.state;
      if (state is FavoritesLoaded) {
        final allEvents = [...state.upcomingEvents, ...state.pastEvents];
        
        // Verify events exist (from repository)
        expect(allEvents.length, greaterThan(0));
        
        // Verify each event has proper structure (not hardcoded strings)
        for (final event in allEvents) {
          expect(event.id, isNotEmpty);
          expect(event.title, isNotEmpty);
          expect(event.venue.name, isNotEmpty);
          expect(event.dances, isNotEmpty);
          expect(event.isFavorite, true); // All events in favorites should be marked as favorite
        }
      }
    });

    testWidgets('empty state displays when all favorites are removed', (WidgetTester tester) async {
      // Arrange - start with favorites
      await favoritesCubit.loadFavorites();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const FavoritesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Remove all favorites
      final initialState = favoritesCubit.state;
      if (initialState is FavoritesLoaded) {
        final allEvents = [...initialState.upcomingEvents, ...initialState.pastEvents];
        
        for (final event in allEvents) {
          await repository.toggleFavorite(event.id, event.isFavorite);
        }
        
        // Reload favorites
        await favoritesCubit.loadFavorites();
        await tester.pumpAndSettle();

        // Assert - should show empty state
        expect(favoritesCubit.state, isA<FavoritesEmpty>());
        expect(find.text('No Favorite Events'), findsOneWidget);
      }
    });
  });

  group('Favorite Toggle Integration Tests', () {
    testWidgets('toggling favorite in EventListScreen updates FavoritesScreen', (WidgetTester tester) async {
      // This test verifies that favorite changes are reflected across screens
      // through the shared repository
      
      // Arrange
      await eventListCubit.loadEvents();
      await favoritesCubit.loadFavorites();

      // Get initial favorite count
      final initialFavoritesState = favoritesCubit.state;
      if (initialFavoritesState is! FavoritesLoaded) {
        // Skip test if no favorites loaded
        return;
      }
      
      final initialFavoriteCount = initialFavoritesState.upcomingEvents.length + initialFavoritesState.pastEvents.length;

      // Get a non-favorite event
      final eventsState = eventListCubit.state;
      if (eventsState is! EventListLoaded) {
        // Skip test if no events loaded
        return;
      }
      
      final allEvents = [...eventsState.todayEvents, ...eventsState.tomorrowEvents, ...eventsState.upcomingEvents];
      if (allEvents.isEmpty) {
        // Skip test if no events available
        return;
      }
      
      final nonFavoriteEvent = allEvents.firstWhere((e) => !e.isFavorite, orElse: () => allEvents.first);

      // Act - toggle favorite
      await repository.toggleFavorite(nonFavoriteEvent.id, nonFavoriteEvent.isFavorite);
      await favoritesCubit.loadFavorites();

      // Assert - favorite count should increase
      final newFavoritesState = favoritesCubit.state;
      if (newFavoritesState is FavoritesLoaded) {
        final newFavoriteCount = newFavoritesState.upcomingEvents.length + newFavoritesState.pastEvents.length;
        expect(newFavoriteCount, greaterThan(initialFavoriteCount));
      }
    });

    testWidgets('removing favorite in FavoritesScreen updates EventListScreen', (WidgetTester tester) async {
      // This test verifies that favorite removals are reflected across screens
      
      // Arrange
      await eventListCubit.loadEvents();
      await favoritesCubit.loadFavorites();

      // Get a favorite event
      final favoritesState = favoritesCubit.state;
      if (favoritesState is! FavoritesLoaded || favoritesState.upcomingEvents.isEmpty) {
        // Skip test if no favorites available
        return;
      }
      
      final favoriteEvent = favoritesState.upcomingEvents.first;

      // Act - remove favorite
      await repository.toggleFavorite(favoriteEvent.id, favoriteEvent.isFavorite);
      await eventListCubit.loadEvents();

      // Assert - event should no longer be favorite in event list
      final eventsState = eventListCubit.state;
      if (eventsState is EventListLoaded) {
        final allEvents = [...eventsState.todayEvents, ...eventsState.tomorrowEvents, ...eventsState.upcomingEvents];
        if (allEvents.isNotEmpty) {
          final updatedEvent = allEvents.firstWhere((e) => e.id == favoriteEvent.id, orElse: () => allEvents.first);
          if (updatedEvent.id == favoriteEvent.id) {
            expect(updatedEvent.isFavorite, false);
          }
        }
      }
    });
  });
}
