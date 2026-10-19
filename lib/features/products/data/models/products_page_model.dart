import '../../domain/entities/products_page.dart';
import 'product_model.dart';

/// Data Transfer Object representing a paginated response from `GET /store/products`.
///
/// Strictly mirrors pagination fields verified from server:
/// - `total` (int)
/// - `totalPages` (int)
/// - `page` (int)
/// - `limit` (int)
/// - `data` (List of ProductModel)
class ProductsPageModel extends ProductsPage {
  const ProductsPageModel({
    required super.total,
    required super.totalPages,
    required super.page,
    required super.limit,
    required List<ProductModel> super.products,
  });

  /// Creates a [ProductsPageModel] from the top-level API response map.
  factory ProductsPageModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'];
    final List<ProductModel> productModels = [];

    if (rawList is List) {
      for (final item in rawList) {
        if (item is Map<String, dynamic>) {
          productModels.add(ProductModel.fromJson(item));
        } else if (item is Map) {
          productModels.add(
            ProductModel.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    final total = _parseInt(json['total']) ?? productModels.length;
    final totalPages = _parseInt(json['totalPages']) ?? 1;
    final page = _parseInt(json['page']) ?? 1;
    final limit = _parseInt(json['limit']) ??
        (productModels.isEmpty ? 20 : productModels.length);

    return ProductsPageModel(
      total: total,
      totalPages: totalPages,
      page: page,
      limit: limit,
      products: productModels,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Converts this model to a pure domain [ProductsPage] entity.
  ProductsPage toEntity() {
    return ProductsPage(
      total: total,
      totalPages: totalPages,
      page: page,
      limit: limit,
      products: products
          .map((p) => p is ProductModel ? p.toEntity() : p)
          .toList(),
    );
  }
}
