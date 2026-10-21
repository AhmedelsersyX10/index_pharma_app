import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import '../../domain/repositories/products_repository.dart';
import 'product_details_state.dart';

/// Cubit responsible for loading and managing single product details.
class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit({
    required ProductsRepository productsRepository,
    StorageService? storageService,
  })  : _productsRepository = productsRepository,
        _storageService = storageService,
        super(const ProductDetailsInitial());

  final ProductsRepository _productsRepository;
  final StorageService? _storageService;

  String? _lastProductId;
  String? _lastBranchId;

  /// Loads product details for [productId] and [branchId].
  ///
  /// If [branchId] is omitted, falls back to the persisted active branch from [StorageService].
  Future<void> loadProductDetails({
    required String productId,
    String? branchId,
  }) async {
    final effectiveBranchId =
        branchId ?? _lastBranchId ?? _storageService?.selectedBranchId;

    _lastProductId = productId;
    _lastBranchId = effectiveBranchId;

    if (effectiveBranchId == null || effectiveBranchId.trim().isEmpty) {
      emit(
        const ProductDetailsFailure(
          Validation(
            serverMessage: 'branch_required',
          ),
        ),
      );
      return;
    }

    if (productId.trim().isEmpty) {
      emit(
        const ProductDetailsFailure(
          Validation(
            serverMessage: 'product_id_invalid',
          ),
        ),
      );
      return;
    }

    emit(const ProductDetailsLoading());

    final result = await _productsRepository.getProductDetails(
      productId: productId.trim(),
      branchId: effectiveBranchId.trim(),
    );

    switch (result) {
      case Success(:final data):
        emit(ProductDetailsLoaded(data));
      case Err(:final failure):
        emit(ProductDetailsFailure(failure));
    }
  }

  /// Retries fetching product details using the last requested IDs.
  Future<void> retry() async {
    if (_lastProductId != null) {
      await loadProductDetails(
        productId: _lastProductId!,
        branchId: _lastBranchId,
      );
    }
  }
}
