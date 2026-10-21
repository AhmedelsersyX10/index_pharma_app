import 'package:get_it/get_it.dart';
import 'package:index_pharma/core/network/api_client.dart';
import '../data/datasources/prescriptions_remote_data_source.dart';
import '../data/datasources/prescriptions_remote_data_source_impl.dart';
import '../data/repositories/prescriptions_repository_impl.dart';
import '../domain/repositories/prescriptions_repository.dart';
import '../presentation/cubit/prescription_cubit.dart';

/// Registers all dependencies for the Prescriptions feature.
void setupPrescriptionsDependencies(GetIt sl) {
  if (!sl.isRegistered<PrescriptionsRemoteDataSource>()) {
    sl.registerLazySingleton<PrescriptionsRemoteDataSource>(
      () => PrescriptionsRemoteDataSourceImpl(
        dio: sl<ApiClient>().dio,
      ),
    );
  }

  if (!sl.isRegistered<PrescriptionsRepository>()) {
    sl.registerLazySingleton<PrescriptionsRepository>(
      () => PrescriptionsRepositoryImpl(
        remoteDataSource: sl<PrescriptionsRemoteDataSource>(),
      ),
    );
  }

  if (!sl.isRegistered<PrescriptionCubit>()) {
    sl.registerFactory<PrescriptionCubit>(
      () => PrescriptionCubit(
        repository: sl<PrescriptionsRepository>(),
      ),
    );
  }
}
