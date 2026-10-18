import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/features/choose_branshs/domain/entities/branch_entity.dart';

/// Contract defining branch retrieval operations for the application.
///
/// Implemented in the data layer by `BranchRepositoryImpl`.
/// Consumed by presentation cubits or domain use cases.
abstract interface class BranchRepository {
  /// Retrieves active store branches.
  Future<ApiResult<List<BranchEntity>>> getBranches();
}
