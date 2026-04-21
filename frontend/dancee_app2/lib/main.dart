import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/service_locator.dart';
import 'core/theme.dart';
import 'i18n/strings.g.dart';
import 'logic/cubits/event_cubit.dart';
import 'logic/cubits/course_cubit.dart';
import 'logic/cubits/favorites_cubit.dart';
import 'logic/cubits/filter_cubit.dart';
import 'logic/cubits/settings_cubit.dart';
import 'logic/states/favorites_state.dart';
import 'logic/states/filter_state.dart';
import 'logic/states/settings_state.dart';
import 'shared/elements/navigation/app_bottom_nav_bar.dart';
import 'shared/elements/navigation/main_shell.dart';
import 'screens/auth/login/login_screen.dart';
import 'screens/auth/register/register_screen.dart';
import 'screens/auth/forgot_password/forgot_password_screen.dart';
import 'screens/auth/onboarding/onboarding_screen.dart';
import 'screens/events/events_list/events_list_screen.dart';
import 'screens/events/event_detail/event_detail_screen.dart';
import 'screens/events/filter_dance/filter_dance_screen.dart';
import 'screens/events/filter_location/filter_location_screen.dart';
import 'screens/courses/courses_list/courses_list_screen.dart';
import 'screens/courses/course_detail/course_detail_screen.dart';
import 'screens/profile/profile/profile_screen.dart';
import 'screens/profile/profile_edit/profile_edit_screen.dart';
import 'screens/profile/change_password/change_password_screen.dart';
import 'screens/profile/premium/premium_screen.dart';
import 'screens/profile/author_contact/author_contact_screen.dart';
import 'screens/saved/saved_events_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  final settingsCubit = sl<SettingsCubit>();
  await settingsCubit.init();
  runApp(TranslationProvider(
    child: DanceeApp(settingsCubit: settingsCubit),
  ));
}

final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    // Auth flow
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // Main app — top-level pages wrapped in shell with bottom nav
    ShellRoute(
      builder: (context, state, child) {
        final location = state.uri.path;
        final NavTab currentTab;
        if (location.startsWith('/courses')) {
          currentTab = NavTab.courses;
        } else if (location.startsWith('/profile')) {
          currentTab = NavTab.profile;
        } else if (location.startsWith('/saved')) {
          currentTab = NavTab.saved;
        } else {
          currentTab = NavTab.events;
        }
        return MainShell(currentTab: currentTab, child: child);
      },
      routes: [
        GoRoute(
          path: '/events',
          builder: (context, state) => const EventsListScreen(),
        ),
        GoRoute(
          path: '/courses',
          builder: (context, state) => const CoursesListScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/saved',
          builder: (context, state) => const SavedEventsScreen(),
        ),
      ],
    ),

    // Sub-pages — no bottom nav bar
    GoRoute(
      path: '/events/detail',
      builder: (context, state) {
        final idStr = state.uri.queryParameters['id'] ?? '';
        final id = int.tryParse(idStr) ?? 0;
        return EventDetailScreen(eventId: id);
      },
    ),
    GoRoute(
      path: '/events/filter-dance',
      builder: (context, state) => const FilterDanceScreen(),
    ),
    GoRoute(
      path: '/events/filter-location',
      builder: (context, state) => const FilterLocationScreen(),
    ),
    GoRoute(
      path: '/courses/detail',
      builder: (context, state) {
        final idStr = state.uri.queryParameters['id'] ?? '';
        final id = int.tryParse(idStr) ?? 0;
        return CourseDetailScreen(courseId: id);
      },
    ),
    GoRoute(
      path: '/profile/edit',
      builder: (context, state) => const ProfileEditScreen(),
    ),
    GoRoute(
      path: '/profile/change-password',
      builder: (context, state) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path: '/profile/premium',
      builder: (context, state) => const PremiumScreen(),
    ),
    GoRoute(
      path: '/profile/author-contact',
      builder: (context, state) => const AuthorContactScreen(),
    ),
  ],
);

class DanceeApp extends StatelessWidget {
  const DanceeApp({super.key, required this.settingsCubit});

  final SettingsCubit settingsCubit;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>.value(value: settingsCubit),
        BlocProvider<FilterCubit>(create: (_) => sl<FilterCubit>()),
        BlocProvider<EventCubit>(create: (_) => sl<EventCubit>()),
        BlocProvider<CourseCubit>(create: (_) => sl<CourseCubit>()),
        BlocProvider<FavoritesCubit>(create: (_) => sl<FavoritesCubit>()),
      ],
      child: _AppListeners(
        child: MaterialApp.router(
          title: t.common.appName,
          theme: AppTheme.theme,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
          locale: TranslationProvider.of(context).flutterLocale,
          supportedLocales: AppLocale.values.map((l) => l.flutterLocale).toList(),
        ),
      ),
    );
  }
}

/// Coordinates cross-cubit reactions:
/// - Language changes → re-fetch events, courses, dance styles
/// - Filter changes → apply filters on EventCubit and CourseCubit
class _AppListeners extends StatefulWidget {
  const _AppListeners({required this.child});

  final Widget child;

  @override
  State<_AppListeners> createState() => _AppListenersState();
}

class _AppListenersState extends State<_AppListeners> {
  @override
  void initState() {
    super.initState();
    // Trigger initial data load once cubits are in the tree
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialLoad());
  }

  void _initialLoad() {
    final languageCode = context.read<SettingsCubit>().currentLanguageCode;
    context.read<EventCubit>().loadEvents(languageCode);
    context.read<CourseCubit>().loadCourses(languageCode);
    context.read<FilterCubit>().loadDanceStyles(languageCode);
    context.read<FavoritesCubit>().loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // 7.3 — Language change: re-fetch all data in the new language
        BlocListener<SettingsCubit, SettingsState>(
          listenWhen: (prev, curr) => prev.languageCode != curr.languageCode,
          listener: (context, state) {
            final code = state.languageCode;
            context.read<EventCubit>().loadEvents(code);
            context.read<CourseCubit>().loadCourses(code);
            context.read<FilterCubit>().loadDanceStyles(code);
          },
        ),
        // 7.4 — Filter change: apply new filters to events and courses
        BlocListener<FilterCubit, FilterState>(
          listener: (context, filterState) {
            final allStyles = context.read<FilterCubit>().allDanceStyles;
            context.read<EventCubit>().applyFilters(filterState, allStyles);
            context.read<CourseCubit>().applyFilters(filterState, allStyles);
          },
        ),
        // 11.2 — Favorites change: sync isFavorited on EventCubit and CourseCubit
        BlocListener<FavoritesCubit, FavoritesState>(
          listenWhen: (prev, curr) =>
              curr.maybeMap(loaded: (_) => true, orElse: () => false) && prev != curr,
          listener: (context, state) {
            state.maybeMap(
              loaded: (s) {
                final eventCubit = context.read<EventCubit>();
                final courseCubit = context.read<CourseCubit>();
                eventCubit.state.maybeMap(
                  loaded: (es) {
                    for (final event in es.allEvents) {
                      final shouldBeFavorited = s.eventIds.contains(event.id);
                      if (event.isFavorited != shouldBeFavorited) {
                        eventCubit.updateFavoriteStatus(event.id, shouldBeFavorited);
                      }
                    }
                  },
                  orElse: () {},
                );
                courseCubit.state.maybeMap(
                  loaded: (cs) {
                    for (final course in cs.allCourses) {
                      final shouldBeFavorited = s.courseIds.contains(course.id);
                      if (course.isFavorited != shouldBeFavorited) {
                        courseCubit.updateFavoriteStatus(course.id, shouldBeFavorited);
                      }
                    }
                  },
                  orElse: () {},
                );
              },
              orElse: () {},
            );
          },
        ),
      ],
      child: widget.child,
    );
  }
}
