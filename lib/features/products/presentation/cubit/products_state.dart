import 'package:index_pharma/core/errors/failure.dart';
import '../../domain/entities/product.dart';

/// Sealed hierarchy representing UI states for store products.
sealed class ProductsState {
  const ProductsState();
}

/// Initial state before products have been requested.
final class ProductsInitial extends ProductsState {
  const ProductsInitial();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductsInitial && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'ProductsInitial()';
}

/// Loading state emitted while the first page of products is loading.
final class ProductsLoading extends ProductsState {
  const ProductsLoading();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductsLoading && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'ProductsLoading()';
}

/// Loaded state containing the verified list of [products] and pagination progress.
final class ProductsLoaded extends ProductsState {
  const ProductsLoaded({
    required this.products,
    required this.page,
    required this.totalPages,
    required this.total,
    required this.hasReachedMax,
    this.isLoadingMore = false,
    this.loadingMoreError,
    this.branchId = '',
    this.keyword,
    this.selectedCategory,
  });

  /// Accumulated list of products loaded across pages.
  final List<Product> products;

  /// Current 1-based page index.
  final int page;

  /// Total number of available pages on server.
  final int totalPages;

  /// Total count of matching products on server.
  final int total;

  /// True when page >= totalPages or no further products are available.
  final bool hasReachedMax;

  /// True when the next page is currently being retrieved.
  final bool isLoadingMore;

  /// Holds error if [loadMore] attempt fails while preserving existing [products].
  final Failure? loadingMoreError;

  /// Branch ID this catalog is filtered by.
  final String branchId;

  /// Current search keyword filter, if active.
  final String? keyword;

  /// Current category filter, if active.
  final String? selectedCategory;

  ProductsLoaded copyWith({
    List<Product>? products,
    int? page,
    int? totalPages,
    int? total,
    bool? hasReachedMax,
    bool? isLoadingMore,
    Failure? loadingMoreError,
    String? branchId,
    String? keyword,
    String? selectedCategory,
  }) {
    return ProductsLoaded(
      products: products ?? this.products,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      total: total ?? this.total,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingMoreError: loadingMoreError,
      branchId: branchId ?? this.branchId,
      keyword: keyword ?? this.keyword,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductsLoaded &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          totalPages == other.totalPages &&
          total == other.total &&
          hasReachedMax == other.hasReachedMax &&
          isLoadingMore == other.isLoadingMore &&
          loadingMoreError == other.loadingMoreError &&
          branchId == other.branchId &&
          keyword == other.keyword &&
          selectedCategory == other.selectedCategory &&
          _listEquals(products, other.products);

  @override
  int get hashCode => Object.hash(
        runtimeType,
        page,
        totalPages,
        total,
        hasReachedMax,
        isLoadingMore,
        loadingMoreError,
        branchId,
        keyword,
        selectedCategory,
        Object.hashAll(products),
      );

  @override
  String toString() =>
      'ProductsLoaded(productsCount: ${products.length}, page: $page/$totalPages, hasReachedMax: $hasReachedMax, isLoadingMore: $isLoadingMore)';

  static bool _listEquals(List<Product> a, List<Product> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Empty state emitted when no products match the current filters or the branch has no products.
final class ProductsEmpty extends ProductsState {
  const ProductsEmpty({
    this.branchId = '',
    this.keyword,
    this.selectedCategory,
  });

  final String branchId;
  final String? keyword;
  final String? selectedCategory;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductsEmpty &&
          runtimeType == other.runtimeType &&
          branchId == other.branchId &&
          keyword == other.keyword &&
          selectedCategory == other.selectedCategory;

  @override
  int get hashCode => Object.hash(
        runtimeType,
        branchId,
        keyword,
        selectedCategory,
      );

  @override
  String toString() =>
      'ProductsEmpty(branchId: $branchId, keyword: $keyword, category: $selectedCategory)';
}

/// Failure state wrapping a domain-level [failure].
final class ProductsFailure extends ProductsState {
  const ProductsFailure(
    this.failure, {
    this.branchId,
    this.keyword,
    this.selectedCategory,
  });

  final Failure failure;
  final String? branchId;
  final String? keyword;
  final String? selectedCategory;

  /// User-facing message derived from serverMessage or default Arabic fallback.
  String get message => failure.serverMessage ?? 'فشل في تحميل قائمة الأدوية';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductsFailure &&
          runtimeType == other.runtimeType &&
          failure == other.failure &&
          branchId == other.branchId &&
          keyword == other.keyword &&
          selectedCategory == other.selectedCategory;

  @override
  int get hashCode => Object.hash(
        runtimeType,
        failure,
        branchId,
        keyword,
        selectedCategory,
      );

  @override
  String toString() =>
      'ProductsFailure(failure: $failure, message: $message)';
}
