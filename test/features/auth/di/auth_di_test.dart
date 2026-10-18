import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:index_pharma/core/network/api_client.dart';
import 'package:index_pharma/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:index_pharma/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:index_pharma/features/auth/di/auth_di.dart';
import 'package:index_pharma/features/auth/domain/repositories/auth_repository.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_state.dart';

void main() {
  final testGetIt = GetIt.asNewInstance();

  setUp(() async {
    await testGetIt.reset();
  });

  tearDown(() async {
    await testGetIt.reset();
  });

  group('setupAuthDependencies', () {
    test('registers AuthRemoteDataSource, AuthRepository, and AuthCubit into GetIt', () {
      expect(testGetIt.isRegistered<AuthRemoteDataSource>(), isFalse);
      expect(testGetIt.isRegistered<AuthRepository>(), isFalse);
      expect(testGetIt.isRegistered<AuthCubit>(), isFalse);

      final fakeApiClient = ApiClient(
        dio: Dio(),
        cookieJar: CookieJar(),
        enableLogging: false,
      );
      testGetIt.registerSingleton<ApiClient>(fakeApiClient);

      setupAuthDependencies(testGetIt);

      expect(testGetIt.isRegistered<AuthRemoteDataSource>(), isTrue);
      expect(testGetIt.isRegistered<AuthRepository>(), isTrue);
      expect(testGetIt.isRegistered<AuthCubit>(), isTrue);

      final repo = testGetIt<AuthRepository>();
      expect(repo, isA<AuthRepositoryImpl>());

      final cubit = testGetIt<AuthCubit>();
      expect(cubit, isA<AuthCubit>());
      expect(cubit.state, isA<AuthInitial>());

      // Verify onSessionExpired was wired
      expect(fakeApiClient.onSessionExpired, isNotNull);
      fakeApiClient.onSessionExpired!();
      expect(cubit.state, isA<AuthGuest>());
    });

    test('avoids duplicate registration when called multiple times', () {
      final fakeApiClient = ApiClient(
        dio: Dio(),
        cookieJar: CookieJar(),
        enableLogging: false,
      );
      testGetIt.registerSingleton<ApiClient>(fakeApiClient);

      setupAuthDependencies(testGetIt);
      expect(testGetIt.isRegistered<AuthRemoteDataSource>(), isTrue);
      expect(testGetIt.isRegistered<AuthRepository>(), isTrue);
      expect(testGetIt.isRegistered<AuthCubit>(), isTrue);

      expect(() => setupAuthDependencies(testGetIt), returnsNormally);
      expect(testGetIt.isRegistered<AuthRemoteDataSource>(), isTrue);
      expect(testGetIt.isRegistered<AuthRepository>(), isTrue);
      expect(testGetIt.isRegistered<AuthCubit>(), isTrue);
    });
  });
}
