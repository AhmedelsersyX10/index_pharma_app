import 'package:get_it/get_it.dart';
import 'package:index_pharma/core/network/api_client.dart';
import '../data/datasources/categories_remote_data_source.dart';
import '../data/datasources/categories_remote_data_source_impl.dart';
import '../data/repositories/categories_repository_impl.dart';
import '../domain/repositories/categories_repository.dart';
import '../presentation/cubit/categories_cubit.dart';

/// Registers categories feature dependencies into [GetIt].
///
/// Follows project architectural rules:
/// - Feature owns its own DI registration.
/// - Registers [CategoriesRemoteDataSource], [CategoriesRepository], and [CategoriesCubit].
/// - Safe against duplicate registration attempts.
void setupCategoriesDependencies([GetIt? sl]) {
  final locator = sl ?? GetIt.instance;

  if (!locator.isRegistered<CategoriesRemoteDataSource>()) {
    locator.registerLazySingleton<CategoriesRemoteDataSource>(
      () => CategoriesRemoteDataSourceImpl(
        dio: locator<ApiClient>().dio,
      ),
    );
  }

  if (!locator.isRegistered<CategoriesRepository>()) {
    locator.registerLazySingleton<CategoriesRepository>(
      () => CategoriesRepositoryImpl(
        remoteDataSource: locator<CategoriesRemoteDataSource>(),
      ),
    );
  }

  if (!locator.isRegistered<CategoriesCubit>()) {
    locator.registerFactory<CategoriesCubit>(
      () => CategoriesCubit(
        categoriesRepository: locator<CategoriesRepository>(),
      ),
    );
  }
}
