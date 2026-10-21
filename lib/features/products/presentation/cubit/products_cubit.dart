import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import '../../domain/repositories/products_repository.dart';
import 'products_state.dart';

/// State management Cubit for store products with pagination, debounced search,
/// category filtering, and branch-switching capabilities.
class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit({
    required ProductsRepository productsRepository,
    StorageService? storageService,
    this.pageSize = 20,
  })  : _productsRepository = productsRepository,
        _storageService = storageService,
        super(const ProductsInitial());

  final ProductsRepository _productsRepository;
  final StorageService? _storageService;
  final int pageSize;

  Timer? _debounceTimer;

  String? _branchId;
  String? _keyword;
  String? _selectedCategory;

  /// The active branch ID.
  String? get currentBranchId =>
      _branchId ?? _storageService?.selectedBranchId;

  /// The active search keyword filter.
  String? get currentKeyword => _keyword;

  /// The active category filter.
  String? get currentCategory => _selectedCategory;

  /// Loads the first page of products for the specified or current branch.
  Future<void> loadFirstPage({String? branchId}) async {
    final effectiveBranchId =
        branchId ?? _branchId ?? _storageService?.selectedBranchId;

    if (effectiveBranchId == null || effectiveBranchId.trim().isEmpty) {
      emit(
        const ProductsFailure(
          Validation(
            serverMessage: 'branch_required',
          ),
        ),
      );
      return;
    }

    _branchId = effectiveBranchId;
    emit(const ProductsLoading());

    final result = await _productsRepository.getProducts(
      branchId: effectiveBranchId,
      page: 1,
      limit: pageSize,
      keyword: _keyword,
      category: _selectedCategory,
    );

    switch (result) {
      case Success(:final data):
        if (data.products.isEmpty) {
          emit(
            ProductsEmpty(
              branchId: effectiveBranchId,
              keyword: _keyword,
              selectedCategory: _selectedCategory,
            ),
          );
        } else {
          emit(
            ProductsLoaded(
              products: data.products,
              page: data.page,
              totalPages: data.totalPages,
              total: data.total,
              hasReachedMax: data.isLastPage,
              branchId: effectiveBranchId,
              keyword: _keyword,
              selectedCategory: _selectedCategory,
            ),
          );
        }
      case Err(:final failure):
        emit(
          ProductsFailure(
            failure,
            branchId: effectiveBranchId,
            keyword: _keyword,
            selectedCategory: _selectedCategory,
          ),
        );
    }
  }

  /// Fetches the subsequent page of products and appends to the current list.
  ///
  /// Guarantees:
  /// - Stops and no-ops when the last page has been reached.
  /// - Prevents concurrent `loadMore` invocations.
  /// - Preserves already loaded products in case of pagination failure.
  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! ProductsLoaded) return;
    if (currentState.hasReachedMax || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true, loadingMoreError: null));

    final nextPage = currentState.page + 1;
    final result = await _productsRepository.getProducts(
      branchId: currentState.branchId,
      page: nextPage,
      limit: pageSize,
      keyword: _keyword,
      category: _selectedCategory,
    );

    switch (result) {
      case Success(:final data):
        final accumulatedProducts = [
          ...currentState.products,
          ...data.products,
        ];

        emit(
          currentState.copyWith(
            products: accumulatedProducts,
            page: data.page,
            totalPages: data.totalPages,
            total: data.total,
            hasReachedMax: data.isLastPage || data.products.isEmpty,
            isLoadingMore: false,
          ),
        );
      case Err(:final failure):
        emit(
          currentState.copyWith(
            isLoadingMore: false,
            loadingMoreError: failure,
          ),
        );
    }
  }

  /// Searches products with a debounce delay (default 400ms).
  void onKeywordChanged(
    String keyword, {
    Duration debounceDuration = const Duration(milliseconds: 400),
  }) {
    final trimmed = keyword.trim();
    if (trimmed == (_keyword ?? '')) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () {
      _keyword = trimmed.isEmpty ? null : trimmed;
      loadFirstPage();
    });
  }

  /// Immediately applies keyword search without debouncing.
  Future<void> setKeywordImmediate(String? keyword) async {
    _debounceTimer?.cancel();
    final trimmed = keyword?.trim();
    _keyword = (trimmed != null && trimmed.isNotEmpty) ? trimmed : null;
    await loadFirstPage();
  }

  /// Sets or toggles category filter.
  Future<void> onCategoryChanged(String? categoryId) async {
    _debounceTimer?.cancel();
    // Toggle if same category tapped again
    if (_selectedCategory == categoryId) {
      _selectedCategory = null;
    } else {
      _selectedCategory = categoryId;
    }
    await loadFirstPage();
  }

  /// Reloads products when the selected branch changes.
  Future<void> reloadForBranch(String newBranchId) async {
    _debounceTimer?.cancel();
    _branchId = newBranchId;
    await loadFirstPage(branchId: newBranchId);
  }

  /// Retries the previous failed operation (loadFirstPage or loadMore).
  Future<void> retry() async {
    final currentState = state;
    if (currentState is ProductsLoaded &&
        currentState.loadingMoreError != null) {
      await loadMore();
    } else {
      await loadFirstPage();
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
