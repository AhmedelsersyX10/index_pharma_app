import 'package:index_pharma/core/network/api_result.dart';
import '../entities/product.dart';
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

  /// Retrieves details for a specific product by [productId] within [branchId].
  ///
  /// Returns [Success] with [Product] on success, or [Err] with [Failure].
  Future<ApiResult<Product>> getProductDetails({
    required String productId,
    required String branchId,
  });
}
