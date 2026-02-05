import 'package:get_it/get_it.dart';
import '../repositories/event_repository.dart';
import '../cubits/event_list/event_list_cubit.dart';
import '../cubits/favorites/favorites_cubit.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Register repository as lazy singleton
  getIt.registerLazySingleton<EventRepository>(
    () => EventRepository(),
  );
  
  // Register cubits as lazy singletons with automatic data loading
  getIt.registerLazySingleton<EventListCubit>(
    () => EventListCubit(getIt<EventRepository>())..loadEvents(),
  );
  
  getIt.registerLazySingleton<FavoritesCubit>(
    () => FavoritesCubit(getIt<EventRepository>())..loadFavorites(),
  );
}
