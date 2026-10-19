import 'product.dart';

/// Pure domain entity representing a paginated page of store products.
///
/// Strictly matches the pagination shape from `GET /store/products`:
/// - `total`: Total number of products across all pages
/// - `totalPages`: Total number of pages
/// - `page`: Current page number (1-based)
/// - `limit`: Number of items per page
/// - `products`: List of [Product] items on this page
class ProductsPage {
  const ProductsPage({
    required this.total,
    required this.totalPages,
    required this.page,
    required this.limit,
    required this.products,
  });

  /// Total count of matching products available in the branch.
  final int total;

  /// Total count of pages available.
  final int totalPages;

  /// Current 1-based page index.
  final int page;

  /// Maximum items returned per page.
  final int limit;

  /// Items returned on this specific page.
  final List<Product> products;

  /// Whether this is the final page of products.
  bool get isLastPage => page >= totalPages;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductsPage &&
          runtimeType == other.runtimeType &&
          total == other.total &&
          totalPages == other.totalPages &&
          page == other.page &&
          limit == other.limit &&
          _listEquals(products, other.products);

  @override
  int get hashCode => Object.hash(
        runtimeType,
        total,
        totalPages,
        page,
        limit,
        Object.hashAll(products),
      );

  @override
  String toString() =>
      'ProductsPage(total: $total, totalPages: $totalPages, page: $page, limit: $limit, count: ${products.length})';

  static bool _listEquals(List<Product> a, List<Product> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
