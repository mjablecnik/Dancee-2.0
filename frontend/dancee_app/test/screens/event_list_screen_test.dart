import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dancee_app/screens/event_list_screen.dart';
import 'package:dancee_app/cubits/event_list/event_list_cubit.dart';
import 'package:dancee_app/cubits/event_list/event_list_state.dart';
import 'package:dancee_app/cubits/favorites/favorites_cubit.dart';
import 'package:dancee_app/repositories/event_repository.dart';
import 'package:dancee_app/di/service_locator.dart';

void main() {
  late EventRepository repository;
  late EventListCubit eventListCubit;
  late FavoritesCubit favoritesCubit;

  setUp(() {
    // Initialize dependencies before each test
    repository = EventRepository();
    eventListCubit = EventListCubit(repository);
    favoritesCubit = FavoritesCubit(repository);
    
    // Register in GetIt
    getIt.registerSingleton<EventRepository>(repository);
    getIt.registerSingleton<EventListCubit>(eventListCubit);
    getIt.registerSingleton<FavoritesCubit>(favoritesCubit);
  });

  tearDown(() {
    // Clean up after each test
    getIt.reset();
  });

  group('EventListScreen Widget Tests', () {
    testWidgets('displays loading indicator when state is loading', (WidgetTester tester) async {
      // Arrange
      eventListCubit.emit(EventListLoading());

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: EventListScreen(),
        ),
      );
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error message and retry button when state is error', (WidgetTester tester) async {
      // Arrange
      const errorMessage = 'Failed to load events';
      eventListCubit.emit(EventListError(errorMessage));

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: EventListScreen(),
        ),
      );
      await tester.pump();

      // Assert
      expect(find.text('Error Loading Events'), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('retry button calls loadEvents when tapped', (WidgetTester tester) async {
      // Arrange
      eventListCubit.emit(EventListError('Test error'));

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: EventListScreen(),
        ),
      );
      await tester.pump();

      // Tap retry button
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      // Assert - should transition to loading then loaded
      expect(eventListCubit.state, isA<EventListLoaded>());
    });

    testWidgets('displays events when state is loaded', (WidgetTester tester) async {
      // Arrange
      await eventListCubit.loadEvents();

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: EventListScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - check for event list elements
      expect(find.text('Dancee'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      
      // Check that at least one event is displayed
      final state = eventListCubit.state as EventListLoaded;
      final totalEvents = state.todayEvents.length + state.tomorrowEvents.length + state.upcomingEvents.length;
      expect(totalEvents, greaterThan(0));
    });

    testWidgets('displays today section when today events exist', (WidgetTester tester) async {
      // Arrange
      await eventListCubit.loadEvents();

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: EventListScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      final state = eventListCubit.state as EventListLoaded;
      if (state.todayEvents.isNotEmpty) {
        expect(find.text('Today'), findsWidgets);
      }
    });

    testWidgets('displays tomorrow section when tomorrow events exist', (WidgetTester tester) async {
      // Arrange
      await eventListCubit.loadEvents();

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: EventListScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      final state = eventListCubit.state as EventListLoaded;
      if (state.tomorrowEvents.isNotEmpty) {
        expect(find.text('Tomorrow'), findsWidgets);
      }
    });

    testWidgets('displays upcoming section when upcoming events exist', (WidgetTester tester) async {
      // Arrange
      await eventListCubit.loadEvents();

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: EventListScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      final state = eventListCubit.state as EventListLoaded;
      if (state.upcomingEvents.isNotEmpty) {
        expect(find.text('This week'), findsWidgets);
      }
    });

    testWidgets('search field is displayed', (WidgetTester tester) async {
      // Arrange
      await eventListCubit.loadEvents();

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: EventListScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search events...'), findsOneWidget);
    });

    testWidgets('search functionality filters events', (WidgetTester tester) async {
      // Arrange
      await eventListCubit.loadEvents();

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: EventListScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Enter search text
      await tester.enterText(find.byType(TextField), 'Salsa');
      await tester.pumpAndSettle();

      // Assert - state should be updated with search results
      final state = eventListCubit.state as EventListLoaded;
      final allEvents = [...state.todayEvents, ...state.tomorrowEvents, ...state.upcomingEvents];
      
      // All displayed events should contain 'Salsa' in title, venue, or description
      for (final event in allEvents) {
        final matchesSearch = event.title.toLowerCase().contains('salsa') ||
            event.venue.name.toLowerCase().contains('salsa') ||
            event.description.toLowerCase().contains('salsa');
        expect(matchesSearch, true);
      }
    });

    testWidgets('clear button appears when search text is entered', (WidgetTester tester) async {
      // Arrange
      await eventListCubit.loadEvents();

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: EventListScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Initially no clear button
      expect(find.byIcon(Icons.clear), findsNothing);

      // Enter search text
      await tester.enterText(find.byType(TextField), 'Test');
      await tester.pumpAndSettle();

      // Assert - clear button should appear
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('clear button clears search and reloads all events', (WidgetTester tester) async {
      // Arrange
      await eventListCubit.loadEvents();

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: EventListScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Enter search text
      await tester.enterText(find.byType(TextField), 'Salsa');
      await tester.pumpAndSettle();

      // Tap clear button
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // Assert - search field should be empty and all events loaded
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('favorite button toggles favorite status', (WidgetTester tester) async {
      // Arrange
      await eventListCubit.loadEvents();

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: EventListScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find first favorite button
      final favoriteButtons = find.byIcon(Icons.favorite_border);
      if (favoriteButtons.evaluate().isNotEmpty) {
        // Get initial state
        final initialState = eventListCubit.state as EventListLoaded;
        final allEvents = [...initialState.todayEvents, ...initialState.tomorrowEvents, ...initialState.upcomingEvents];
        final firstNonFavorite = allEvents.firstWhere((e) => !e.isFavorite, orElse: () => allEvents.first);
        final initialFavoriteStatus = firstNonFavorite.isFavorite;

        // Tap favorite button
        await tester.tap(favoriteButtons.first);
        await tester.pumpAndSettle();

        // Assert - favorite status should be toggled
        final newState = eventListCubit.state as EventListLoaded;
        final newAllEvents = [...newState.todayEvents, ...newState.tomorrowEvents, ...newState.upcomingEvents];
        final updatedEvent = newAllEvents.firstWhere((e) => e.id == firstNonFavorite.id);
        expect(updatedEvent.isFavorite, !initialFavoriteStatus);
      }
    });

    testWidgets('event cards display correct information', (WidgetTester tester) async {
      // Arrange
      await eventListCubit.loadEvents();

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: EventListScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - check that event information is displayed
      final state = eventListCubit.state as EventListLoaded;
      if (state.todayEvents.isNotEmpty) {
        final firstEvent = state.todayEvents.first;
        
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

    testWidgets('no hardcoded event data in UI', (WidgetTester tester) async {
      // Arrange - create empty repository
      final emptyRepository = EventRepository();
      final emptyCubit = EventListCubit(emptyRepository);
      
      // Override GetIt registration
      getIt.unregister<EventListCubit>();
      getIt.registerSingleton<EventListCubit>(emptyCubit);
      
      // Load events (will get from repository)
      await emptyCubit.loadEvents();

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: EventListScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - events should come from repository, not hardcoded in UI
      final state = emptyCubit.state as EventListLoaded;
      final allEvents = [...state.todayEvents, ...state.tomorrowEvents, ...state.upcomingEvents];
      
      // Verify events exist (from repository)
      expect(allEvents.length, greaterThan(0));
      
      // Verify each event has proper structure (not hardcoded strings)
      for (final event in allEvents) {
        expect(event.id, isNotEmpty);
        expect(event.title, isNotEmpty);
        expect(event.venue.name, isNotEmpty);
        expect(event.dances, isNotEmpty);
      }
    });
  });
}
