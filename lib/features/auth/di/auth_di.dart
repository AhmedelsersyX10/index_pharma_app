import 'package:get_it/get_it.dart';
import 'package:index_pharma/core/network/api_client.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../data/datasources/auth_remote_data_source_impl.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/services/permission_service.dart';
import '../presentation/cubit/auth_cubit.dart';
import '../presentation/cubit/auth_state.dart';

/// Registers authentication feature dependencies into [GetIt].
///
/// Follows project architectural rules:
/// - Feature owns its DI setup.
/// - Registers [AuthRemoteDataSource], [AuthRepository], [AuthCubit], and [PermissionService].
/// - Wires [ApiClient.onSessionExpired] to [AuthCubit.onSessionExpired].
/// - Safe against duplicate registration attempts.
void setupAuthDependencies([GetIt? sl]) {
  final locator = sl ?? GetIt.instance;

  if (!locator.isRegistered<AuthRemoteDataSource>()) {
    locator.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        dio: locator<ApiClient>().dio,
      ),
    );
  }

  if (!locator.isRegistered<AuthRepository>()) {
    locator.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: locator<AuthRemoteDataSource>(),
      ),
    );
  }

  if (!locator.isRegistered<AuthCubit>()) {
    locator.registerLazySingleton<AuthCubit>(
      () {
        final client = locator.isRegistered<ApiClient>()
            ? locator<ApiClient>()
            : null;
        final cubit = AuthCubit(
          authRepository: locator<AuthRepository>(),
          apiClient: client,
        );
        client?.onSessionExpired = cubit.onSessionExpired;
        return cubit;
      },
    );
  }

  if (!locator.isRegistered<PermissionService>()) {
    locator.registerFactory<PermissionService>(
      () {
        if (locator.isRegistered<AuthCubit>()) {
          final authState = locator<AuthCubit>().state;
          if (authState is AuthAuthenticated) {
            return PermissionService(authState.user);
          }
        }
        return const PermissionService();
      },
    );
  }
}
