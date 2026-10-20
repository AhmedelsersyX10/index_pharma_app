import '../models/product_model.dart';
import '../models/products_page_model.dart';

/// Contract for fetching products from the remote Index Pharma Store API.
abstract class ProductsRemoteDataSource {
  /// Fetches a paginated page of store products.
  ///
  /// Parameters:
  /// - [branchId]: Mandatory branch identifier (without it the server returns 400).
  /// - [page]: 1-based page number (defaults to 1).
  /// - [limit]: Number of items per page (defaults to 20, max 100).
  /// - [keyword]: Search term matching name, scientific name, or barcode.
  /// - [category]: Optional category ID or name filter.
  Future<ProductsPageModel> getProducts({
    required String branchId,
    int page = 1,
    int limit = 20,
    String? keyword,
    String? category,
  });

  /// Fetches single product details by [productId] within [branchId].
  ///
  /// Calls `GET /store/products/:id?branchId=:branchId`.
  Future<ProductModel> getProductById({
    required String productId,
    required String branchId,
  });
}
