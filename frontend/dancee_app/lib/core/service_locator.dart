import 'package:get_it/get_it.dart';

import 'clients.dart';
import 'config.dart';

// Feature repositories
import '../features/events/data/event_repository.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/settings/data/settings_repository.dart';

// Feature cubits
import '../features/events/logic/event_list.dart';
import '../features/events/logic/favorites.dart';
import '../features/auth/logic/auth.dart';
import '../features/settings/logic/settings.dart';
import '../features/events/logic/event_detail.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Register DirectusClient as lazy singleton
  getIt.registerLazySingleton<DirectusClient>(
    () => DirectusClient(
      baseUrl: AppConfig.directusBaseUrl,
      accessToken: AppConfig.directusAccessToken,
    ),
  );

  // Register repositories as lazy singletons
  getIt.registerLazySingleton<EventRepository>(
    () => EventRepository(getIt<DirectusClient>()),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<DirectusClient>()),
  );

  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepository(getIt<DirectusClient>()),
  );

  // Register cubits
  getIt.registerLazySingleton<EventListCubit>(
    () => EventListCubit(getIt<EventRepository>()),
  );

  getIt.registerLazySingleton<FavoritesCubit>(
    () => FavoritesCubit(getIt<EventRepository>()),
  );

  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(getIt<AuthRepository>()),
  );

  getIt.registerFactory<SettingsCubit>(
    () => SettingsCubit(getIt<SettingsRepository>()),
  );

  getIt.registerFactoryParam<EventDetailCubit, String, void>(
    (eventId, _) => EventDetailCubit(
      eventListCubit: getIt<EventListCubit>(),
      eventId: eventId,
    ),
  );
}
