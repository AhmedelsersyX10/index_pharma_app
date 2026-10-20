import '../entities/cart_item.dart';

/// Abstract contract for managing shopping cart persistence and branch scoping.
abstract class CartRepository {
  /// Loads all cart items associated with [branchId].
  Future<List<CartItem>> getCartItems(String branchId);

  /// Saves the updated cart items for [branchId].
  Future<void> saveCartItems(String branchId, List<CartItem> items);

  /// Clears all cart items for [branchId].
  Future<void> clearCart(String branchId);

  /// Gets the currently recorded active cart branch ID, if any.
  Future<String?> getActiveCartBranchId();

  /// Sets the currently recorded active cart branch ID.
  Future<void> setActiveCartBranchId(String? branchId);
}
