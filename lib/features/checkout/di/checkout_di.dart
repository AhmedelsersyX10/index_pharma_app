import 'package:get_it/get_it.dart';
import 'package:index_pharma/core/network/api_client.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_state.dart';
import 'package:index_pharma/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:index_pharma/features/products/domain/repositories/products_repository.dart';
import '../data/datasources/checkout_remote_data_source.dart';
import '../data/datasources/checkout_remote_data_source_impl.dart';
import '../data/repositories/checkout_repository_impl.dart';
import '../domain/repositories/checkout_repository.dart';
import '../presentation/cubit/checkout_cubit.dart';

/// Registers checkout dependencies into [GetIt].
///
/// Follows project architectural rules:
/// - Feature owns its DI setup.
/// - Registers [CheckoutRemoteDataSource] and [CheckoutRepository].
/// - Registers [CheckoutCubit] as a factory scoped to the checkout screen.
void setupCheckoutDependencies([GetIt? sl]) {
  final locator = sl ?? GetIt.instance;

  if (!locator.isRegistered<CheckoutRemoteDataSource>()) {
    locator.registerLazySingleton<CheckoutRemoteDataSource>(
      () => CheckoutRemoteDataSourceImpl(
        dio: locator<ApiClient>().dio,
      ),
    );
  }

  if (!locator.isRegistered<CheckoutRepository>()) {
    locator.registerLazySingleton<CheckoutRepository>(
      () => CheckoutRepositoryImpl(
        remoteDataSource: locator<CheckoutRemoteDataSource>(),
      ),
    );
  }

  if (!locator.isRegistered<CheckoutCubit>()) {
    locator.registerFactory<CheckoutCubit>(
      () {
        String userAddress = '';
        String userPhone = '';
        if (locator.isRegistered<AuthCubit>()) {
          final authState = locator<AuthCubit>().state;
          if (authState is AuthAuthenticated) {
            userAddress = authState.user.address ?? '';
            userPhone = authState.user.phone ?? '';
          }
        }

        return CheckoutCubit(
          checkoutRepository: locator<CheckoutRepository>(),
          cartCubit: locator<CartCubit>(),
          productsRepository: locator.isRegistered<ProductsRepository>()
              ? locator<ProductsRepository>()
              : null,
          initialAddress: userAddress,
          initialPhone: userPhone,
        );
      },
    );
  }
}
