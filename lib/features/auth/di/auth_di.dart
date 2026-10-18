import 'package:get_it/get_it.dart';
import 'package:index_pharma/core/network/api_client.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../data/datasources/auth_remote_data_source_impl.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';

/// Registers authentication feature dependencies into [GetIt].
///
/// Follows project architectural rules:
/// - Feature owns its DI setup.
/// - Registers [AuthRemoteDataSource] and [AuthRepository].
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
}
