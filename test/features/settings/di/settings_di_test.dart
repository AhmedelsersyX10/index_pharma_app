import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:index_pharma/core/network/api_client.dart';
import 'package:index_pharma/features/settings/data/datasources/settings_remote_data_source.dart';
import 'package:index_pharma/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:index_pharma/features/settings/di/settings_di.dart';
import 'package:index_pharma/features/settings/domain/repositories/settings_repository.dart';
import 'package:index_pharma/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:index_pharma/features/settings/presentation/cubit/settings_state.dart';

void main() {
  final testGetIt = GetIt.asNewInstance();

  setUp(() async {
    await testGetIt.reset();
  });

  tearDown(() async {
    await testGetIt.reset();
  });

  group('setupSettingsDependencies', () {
    test('registers SettingsRemoteDataSource, SettingsRepository, and SettingsCubit into GetIt', () {
      expect(testGetIt.isRegistered<SettingsRemoteDataSource>(), isFalse);
      expect(testGetIt.isRegistered<SettingsRepository>(), isFalse);
      expect(testGetIt.isRegistered<SettingsCubit>(), isFalse);

      final fakeApiClient = ApiClient(
        dio: Dio(),
        cookieJar: CookieJar(),
        enableLogging: false,
      );
      testGetIt.registerSingleton<ApiClient>(fakeApiClient);

      setupSettingsDependencies(testGetIt);

      expect(testGetIt.isRegistered<SettingsRemoteDataSource>(), isTrue);
      expect(testGetIt.isRegistered<SettingsRepository>(), isTrue);
      expect(testGetIt.isRegistered<SettingsCubit>(), isTrue);

      final repo = testGetIt<SettingsRepository>();
      expect(repo, isA<SettingsRepositoryImpl>());

      final cubit = testGetIt<SettingsCubit>();
      expect(cubit, isA<SettingsCubit>());
      expect(cubit.state, isA<SettingsInitial>());
    });

    test('is safe against multiple calls (no duplicate registration error)', () {
      final fakeApiClient = ApiClient(
        dio: Dio(),
        cookieJar: CookieJar(),
        enableLogging: false,
      );
      testGetIt.registerSingleton<ApiClient>(fakeApiClient);

      setupSettingsDependencies(testGetIt);
      expect(() => setupSettingsDependencies(testGetIt), returnsNormally);

      expect(testGetIt.isRegistered<SettingsRemoteDataSource>(), isTrue);
      expect(testGetIt.isRegistered<SettingsRepository>(), isTrue);
      expect(testGetIt.isRegistered<SettingsCubit>(), isTrue);
    });
  });
}
