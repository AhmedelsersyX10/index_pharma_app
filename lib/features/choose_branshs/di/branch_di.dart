import 'package:get_it/get_it.dart';
import 'package:index_pharma/core/network/api_client.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:index_pharma/features/choose_branshs/data/datasources/branch_remote_data_source.dart';
import 'package:index_pharma/features/choose_branshs/data/datasources/branch_remote_data_source_impl.dart';
import 'package:index_pharma/features/choose_branshs/data/repositories/branch_repository_impl.dart';
import 'package:index_pharma/features/choose_branshs/domain/repositories/branch_repository.dart';
import 'package:index_pharma/features/choose_branshs/presentation/cubit/branch_cubit.dart';

/// Registers branch feature dependencies into [GetIt].
///
/// Follows project architectural rules:
/// - Feature owns its own DI registration.
/// - Registers [BranchRemoteDataSource], [BranchRepository], and [BranchCubit].
/// - Safe against duplicate registration attempts.
void setupBranchDependencies([GetIt? sl]) {
  final locator = sl ?? GetIt.instance;

  if (!locator.isRegistered<BranchRemoteDataSource>()) {
    locator.registerLazySingleton<BranchRemoteDataSource>(
      () => BranchRemoteDataSourceImpl(
        dio: locator<ApiClient>().dio,
      ),
    );
  }

  if (!locator.isRegistered<BranchRepository>()) {
    locator.registerLazySingleton<BranchRepository>(
      () => BranchRepositoryImpl(
        remoteDataSource: locator<BranchRemoteDataSource>(),
      ),
    );
  }

  if (!locator.isRegistered<BranchCubit>()) {
    locator.registerFactory<BranchCubit>(
      () => BranchCubit(
        branchRepository: locator<BranchRepository>(),
        storageService: locator<StorageService>(),
      ),
    );
  }
}
