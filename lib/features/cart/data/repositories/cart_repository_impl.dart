import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_data_source.dart';
import '../models/cart_item_model.dart';

/// Implementation of [CartRepository] using [CartLocalDataSource].
class CartRepositoryImpl implements CartRepository {
  const CartRepositoryImpl({required CartLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  final CartLocalDataSource _localDataSource;

  @override
  Future<List<CartItem>> getCartItems(String branchId) async {
    final models = await _localDataSource.getCartItems(branchId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> saveCartItems(String branchId, List<CartItem> items) async {
    final models = items.map((e) => CartItemModel.fromEntity(e)).toList();
    await _localDataSource.saveCartItems(branchId, models);
  }

  @override
  Future<void> clearCart(String branchId) async {
    await _localDataSource.clearCart(branchId);
  }

  @override
  Future<String?> getActiveCartBranchId() {
    return _localDataSource.getActiveCartBranchId();
  }

  @override
  Future<void> setActiveCartBranchId(String? branchId) {
    return _localDataSource.setActiveCartBranchId(branchId);
  }
}
