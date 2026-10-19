import 'package:dio/dio.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/core/network/error_mapper.dart';
import 'package:index_pharma/features/choose_branches/data/datasources/branch_remote_data_source.dart';
import 'package:index_pharma/features/choose_branches/domain/entities/branch_entity.dart';
import 'package:index_pharma/features/choose_branches/domain/repositories/branch_repository.dart';

/// Data layer implementation of [BranchRepository].
///
/// Calls [BranchRemoteDataSource] to retrieve branch models, maps them to domain
/// entities, and safely converts any exceptions to domain-level [Failure] types.
class BranchRepositoryImpl implements BranchRepository {
  const BranchRepositoryImpl({
    required BranchRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final BranchRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<List<BranchEntity>>> getBranches() async {
    try {
      final models = await _remoteDataSource.getBranches();
      final entities = models.map((m) => m.toEntity()).toList();
      return Success(entities);
    } on DioException catch (e) {
      return Err(e.toFailure());
    } catch (e) {
      return Err(Unexpected(serverMessage: e.toString()));
    }
  }
}
