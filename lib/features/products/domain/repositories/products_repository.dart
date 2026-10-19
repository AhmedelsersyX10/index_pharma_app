import 'package:index_pharma/core/network/api_result.dart';
import '../entities/products_page.dart';

/// Domain contract for repository retrieving products.
abstract class ProductsRepository {
  /// Retrieves a paginated list of products for the given branch.
  ///
  /// Returns [Success] with [ProductsPage] on success, or [Err] with [Failure].
  Future<ApiResult<ProductsPage>> getProducts({
    required String branchId,
    int page = 1,
    int limit = 20,
    String? keyword,
    String? category,
  });
}
