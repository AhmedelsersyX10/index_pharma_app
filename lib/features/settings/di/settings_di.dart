import 'package:get_it/get_it.dart';
import 'package:index_pharma/core/network/api_client.dart';
import '../data/datasources/settings_remote_data_source.dart';
import '../data/datasources/settings_remote_data_source_impl.dart';
import '../data/repositories/settings_repository_impl.dart';
import '../domain/repositories/settings_repository.dart';
import '../presentation/cubit/settings_cubit.dart';

/// Registers settings feature dependencies into [GetIt].
///
/// Follows project architectural rules:
/// - Feature owns its own DI registration.
/// - Registers [SettingsRemoteDataSource], [SettingsRepository], and [SettingsCubit].
/// - Safe against duplicate registration attempts.
void setupSettingsDependencies([GetIt? sl]) {
  final locator = sl ?? GetIt.instance;

  if (!locator.isRegistered<SettingsRemoteDataSource>()) {
    locator.registerLazySingleton<SettingsRemoteDataSource>(
      () => SettingsRemoteDataSourceImpl(
        dio: locator<ApiClient>().dio,
      ),
    );
  }

  if (!locator.isRegistered<SettingsRepository>()) {
    locator.registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(
        remoteDataSource: locator<SettingsRemoteDataSource>(),
      ),
    );
  }

  if (!locator.isRegistered<SettingsCubit>()) {
    locator.registerFactory<SettingsCubit>(
      () => SettingsCubit(
        settingsRepository: locator<SettingsRepository>(),
      ),
    );
  }
}
