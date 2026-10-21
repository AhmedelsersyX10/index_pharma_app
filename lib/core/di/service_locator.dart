import 'package:get_it/get_it.dart';
import 'package:index_pharma/core/network/api_client.dart';
import 'package:index_pharma/core/storage/shared_preferences_storage_service.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:index_pharma/features/auth/domain/entities/user.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_state.dart';
import 'package:index_pharma/features/auth/di/auth_di.dart';
import 'package:index_pharma/features/choose_branches/di/branch_di.dart';
import 'package:index_pharma/features/settings/di/settings_di.dart';
import 'package:index_pharma/features/categories/di/categories_di.dart';
import 'package:index_pharma/features/products/di/products_di.dart';
import 'package:index_pharma/features/cart/di/cart_di.dart';
import 'package:index_pharma/features/checkout/di/checkout_di.dart';
import 'package:index_pharma/features/orders/di/orders_di.dart';
import 'package:index_pharma/features/prescriptions/di/prescriptions_di.dart';

/// Global service locator instance.
final GetIt getIt = GetIt.instance;

/// Sets up dependency injection for the entire application.
///
/// Registers core services and provides hook points for feature modules.
/// Should be called once during app startup in `main.dart` before `runApp`.
Future<void> setupServiceLocator() async {
  _setupCoreServices();
  _setupFeatureDependencies();
  await getIt.allReady();
}

/// Registers core services (networking, local storage, etc.).
void _setupCoreServices() {
  if (!getIt.isRegistered<StorageService>()) {
    getIt.registerSingletonAsync<StorageService>(
      () async {
        final preferences = await SharedPreferences.getInstance();
        return SharedPreferencesStorageService(preferences);
      },
    );
  }

  if (!getIt.isRegistered<ApiClient>()) {
    getIt.registerSingletonAsync<ApiClient>(
      () => ApiClient.create(
        branchIdProvider: () {
          if (getIt.isRegistered<StorageService>()) {
            return getIt<StorageService>().selectedBranchId;
          }
          return null;
        },
        isSuperAdminProvider: () {
          if (getIt.isRegistered<AuthCubit>()) {
            final authState = getIt<AuthCubit>().state;
            return authState is AuthAuthenticated &&
                authState.user.role == UserRole.superadmin;
          }
          return false;
        },
      ),
      dependsOn: [StorageService],
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
  setupAuthDependencies(getIt);
  setupBranchDependencies(getIt);
  setupSettingsDependencies(getIt);
  setupCategoriesDependencies(getIt);
  setupProductsDependencies(getIt);
  setupCartDependencies(getIt);
  setupCheckoutDependencies(getIt);
  setupOrdersDependencies(getIt);
  setupPrescriptionsDependencies(getIt);
}

