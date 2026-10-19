import 'package:index_pharma/features/choose_branches/data/models/branch_model.dart';

/// Contract defining remote network operations for branch retrieval.
///
/// Throws [DioException] on network or HTTP errors, which are mapped to domain
/// [Failure] types at the repository boundary.
abstract interface class BranchRemoteDataSource {
  /// Calls `GET /store/branches` to fetch active store branches.
  Future<List<BranchModel>> getBranches();
}
