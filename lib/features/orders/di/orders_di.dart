import 'package:get_it/get_it.dart';
import 'package:index_pharma/core/network/api_client.dart';
import '../data/datasources/orders_remote_data_source.dart';
import '../data/datasources/orders_remote_data_source_impl.dart';
import '../data/repositories/orders_repository_impl.dart';
import '../domain/repositories/orders_repository.dart';
import '../domain/usecases/get_my_orders_use_case.dart';

/// Registers dependencies for the Customer Orders feature.
void setupOrdersDependencies(GetIt getIt) {
  if (!getIt.isRegistered<OrdersRemoteDataSource>()) {
    getIt.registerLazySingleton<OrdersRemoteDataSource>(
      () => OrdersRemoteDataSourceImpl(dio: getIt<ApiClient>().dio),
    );
  }

  if (!getIt.isRegistered<OrdersRepository>()) {
    getIt.registerLazySingleton<OrdersRepository>(
      () => OrdersRepositoryImpl(
        remoteDataSource: getIt<OrdersRemoteDataSource>(),
      ),
    );
  }

  if (!getIt.isRegistered<GetMyOrdersUseCase>()) {
    getIt.registerLazySingleton<GetMyOrdersUseCase>(
      () => GetMyOrdersUseCase(
        repository: getIt<OrdersRepository>(),
      ),
    );
  }
}
