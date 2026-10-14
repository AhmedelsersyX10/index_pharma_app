import 'package:get_it/get_it.dart';
import 'package:index_pharma/core/network/api_client.dart';
import 'package:index_pharma/core/storage/shared_preferences_storage_service.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global service locator instance.
final GetIt getIt = GetIt.instance;

/// Sets up dependency injection for the entire application.
///
/// Registers core services and provides hook points for feature modules.
/// Should be called once during app startup in `main.dart` before `runApp`.
Future<void> setupServiceLocator() async {
  _setupCoreServices();
  _setupFeatureDependencies();
}

/// Registers core services (networking, local storage, etc.).
void _setupCoreServices() {
  if (!getIt.isRegistered<StorageService>()) {
    getIt.registerLazySingletonAsync<StorageService>(
      () async {
        final preferences = await SharedPreferences.getInstance();
        return SharedPreferencesStorageService(preferences);
      },
    );
  }

  if (!getIt.isRegistered<ApiClient>()) {
    getIt.registerLazySingletonAsync<ApiClient>(
      () => ApiClient.create(
        branchIdProvider: () {
          if (getIt.isRegistered<StorageService>() &&
              getIt.isReadySync<StorageService>()) {
            return getIt<StorageService>().selectedBranchId;
          }
          return null;
        },
      ),
    );
  }

  if (!getIt.isRegistered<AppRouter>()) {
    getIt.registerLazySingleton<AppRouter>(
      () => AppRouter(),
    );
  }
}

/// Placeholder hook for feature modules to register their own dependencies.
///
/// Architecture rules:
/// - Each feature owns its own DI registration file (e.g., `feature_name_di.dart`).
/// - Feature modules register their own data sources, repositories, and use cases.
/// - Do NOT register every Cubit here or in `main.dart`; scope Cubits to the
///   feature route, screen, or flow that requires them.
/// - Call feature registration functions here when new features are added.
void _setupFeatureDependencies() {
  // Feature module registrations will be added here as features are implemented.
  // Example:
  // setupAuthDependencies();
}
