import 'package:get_it/get_it.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/datasources/cart_local_data_source.dart';
import '../data/repositories/cart_repository_impl.dart';
import '../domain/repositories/cart_repository.dart';
import '../presentation/cubit/cart_cubit.dart';

/// Registers shopping cart dependencies into [GetIt].
///
/// Follows project architectural rules:
/// - Feature owns its DI setup.
/// - Registers [CartLocalDataSource], [CartRepository], and [CartCubit].
/// - [CartCubit] is registered as a lazy singleton so its state is shared
///   across Home, Products, Product Details, and Cart screens.
void setupCartDependencies([GetIt? sl]) {
  final locator = sl ?? GetIt.instance;

  if (!locator.isRegistered<CartLocalDataSource>()) {
    locator.registerSingletonAsync<CartLocalDataSource>(
      () async {
        final prefs = await SharedPreferences.getInstance();
        return CartLocalDataSourceImpl(preferences: prefs);
      },
    );
  }

  if (!locator.isRegistered<CartRepository>()) {
    locator.registerSingletonWithDependencies<CartRepository>(
      () => CartRepositoryImpl(
        localDataSource: locator<CartLocalDataSource>(),
      ),
      dependsOn: [CartLocalDataSource],
    );
  }

  if (!locator.isRegistered<CartCubit>()) {
    locator.registerLazySingleton<CartCubit>(
      () => CartCubit(
        cartRepository: locator<CartRepository>(),
        storageService: locator.isRegistered<StorageService>()
            ? locator<StorageService>()
            : null,
      ),
    );
  }
}
