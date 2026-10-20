import 'package:get_it/get_it.dart';
import 'package:index_pharma/core/network/api_client.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import '../data/datasources/products_remote_data_source.dart';
import '../data/datasources/products_remote_data_source_impl.dart';
import '../data/repositories/products_repository_impl.dart';
import '../domain/repositories/products_repository.dart';
import '../presentation/cubit/product_details_cubit.dart';
import '../presentation/cubit/products_cubit.dart';

/// Registers products feature dependencies into [GetIt].
///
/// Follows project architectural rules:
/// - Feature owns its own DI registration.
/// - Registers [ProductsRemoteDataSource], [ProductsRepository], [ProductsCubit], and [ProductDetailsCubit].
/// - Safe against duplicate registration attempts.
void setupProductsDependencies([GetIt? sl]) {
  final locator = sl ?? GetIt.instance;

  if (!locator.isRegistered<ProductsRemoteDataSource>()) {
    locator.registerLazySingleton<ProductsRemoteDataSource>(
      () => ProductsRemoteDataSourceImpl(
        dio: locator<ApiClient>().dio,
      ),
    );
  }

  if (!locator.isRegistered<ProductsRepository>()) {
    locator.registerLazySingleton<ProductsRepository>(
      () => ProductsRepositoryImpl(
        remoteDataSource: locator<ProductsRemoteDataSource>(),
      ),
    );
  }

  if (!locator.isRegistered<ProductsCubit>()) {
    locator.registerFactory<ProductsCubit>(
      () => ProductsCubit(
        productsRepository: locator<ProductsRepository>(),
        storageService: locator.isRegistered<StorageService>()
            ? locator<StorageService>()
            : null,
      ),
    );
  }

  if (!locator.isRegistered<ProductDetailsCubit>()) {
    locator.registerFactory<ProductDetailsCubit>(
      () => ProductDetailsCubit(
        productsRepository: locator<ProductsRepository>(),
        storageService: locator.isRegistered<StorageService>()
            ? locator<StorageService>()
            : null,
      ),
    );
  }
}
