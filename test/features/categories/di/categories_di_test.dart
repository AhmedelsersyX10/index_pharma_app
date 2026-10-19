import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:index_pharma/core/network/api_client.dart';
import 'package:index_pharma/features/categories/data/datasources/categories_remote_data_source.dart';
import 'package:index_pharma/features/categories/data/repositories/categories_repository_impl.dart';
import 'package:index_pharma/features/categories/di/categories_di.dart';
import 'package:index_pharma/features/categories/domain/repositories/categories_repository.dart';
import 'package:index_pharma/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:index_pharma/features/categories/presentation/cubit/categories_state.dart';

void main() {
  final testGetIt = GetIt.asNewInstance();

  setUp(() async {
    await testGetIt.reset();
  });

  tearDown(() async {
    await testGetIt.reset();
  });

  group('setupCategoriesDependencies', () {
    test('registers CategoriesRemoteDataSource, CategoriesRepository, and CategoriesCubit into GetIt', () {
      expect(testGetIt.isRegistered<CategoriesRemoteDataSource>(), isFalse);
      expect(testGetIt.isRegistered<CategoriesRepository>(), isFalse);
      expect(testGetIt.isRegistered<CategoriesCubit>(), isFalse);

      final fakeApiClient = ApiClient(
        dio: Dio(),
        cookieJar: CookieJar(),
        enableLogging: false,
      );
      testGetIt.registerSingleton<ApiClient>(fakeApiClient);

      setupCategoriesDependencies(testGetIt);

      expect(testGetIt.isRegistered<CategoriesRemoteDataSource>(), isTrue);
      expect(testGetIt.isRegistered<CategoriesRepository>(), isTrue);
      expect(testGetIt.isRegistered<CategoriesCubit>(), isTrue);

      final repo = testGetIt<CategoriesRepository>();
      expect(repo, isA<CategoriesRepositoryImpl>());

      final cubit = testGetIt<CategoriesCubit>();
      expect(cubit, isA<CategoriesCubit>());
      expect(cubit.state, isA<CategoriesInitial>());
    });

    test('is safe against multiple calls (no duplicate registration error)', () {
      final fakeApiClient = ApiClient(
        dio: Dio(),
        cookieJar: CookieJar(),
        enableLogging: false,
      );
      testGetIt.registerSingleton<ApiClient>(fakeApiClient);

      setupCategoriesDependencies(testGetIt);
      expect(() => setupCategoriesDependencies(testGetIt), returnsNormally);

      expect(testGetIt.isRegistered<CategoriesRemoteDataSource>(), isTrue);
      expect(testGetIt.isRegistered<CategoriesRepository>(), isTrue);
      expect(testGetIt.isRegistered<CategoriesCubit>(), isTrue);
    });
  });
}
