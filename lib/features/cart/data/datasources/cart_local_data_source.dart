import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';

/// Abstract contract for local cart storage.
abstract class CartLocalDataSource {
  /// Loads cart items for a given [branchId].
  Future<List<CartItemModel>> getCartItems(String branchId);

  /// Persists cart items for a given [branchId].
  Future<void> saveCartItems(String branchId, List<CartItemModel> items);

  /// Clears cart items for a given [branchId].
  Future<void> clearCart(String branchId);

  /// Gets the currently recorded active cart branch ID, if any.
  Future<String?> getActiveCartBranchId();

  /// Sets the currently active cart branch ID.
  Future<void> setActiveCartBranchId(String? branchId);
}

/// SharedPreferences implementation of [CartLocalDataSource].
class CartLocalDataSourceImpl implements CartLocalDataSource {
  const CartLocalDataSourceImpl({required SharedPreferences preferences})
      : _preferences = preferences;

  final SharedPreferences _preferences;

  static const String _keyActiveCartBranchId = 'key_active_cart_branch_id';
  static String _cartItemsKey(String branchId) => 'key_cart_items_$branchId';

  @override
  Future<List<CartItemModel>> getCartItems(String branchId) async {
    final rawJson = _preferences.getString(_cartItemsKey(branchId));
    if (rawJson == null || rawJson.trim().isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map((item) => CartItemModel.fromJson(item))
            .toList();
      }
      return [];
    } catch (_) {
      // In case of corrupt local storage entry, fail safely by clearing
      await clearCart(branchId);
      return [];
    }
  }

  @override
  Future<void> saveCartItems(
      String branchId, List<CartItemModel> items) async {
    if (items.isEmpty) {
      await clearCart(branchId);
      return;
    }

    final rawJson = jsonEncode(items.map((i) => i.toJson()).toList());
    await _preferences.setString(_cartItemsKey(branchId), rawJson);
    await setActiveCartBranchId(branchId);
  }

  @override
  Future<void> clearCart(String branchId) async {
    await _preferences.remove(_cartItemsKey(branchId));
    final activeBranchId = await getActiveCartBranchId();
    if (activeBranchId == branchId) {
      await setActiveCartBranchId(null);
    }
  }

  @override
  Future<String?> getActiveCartBranchId() async {
    return _preferences.getString(_keyActiveCartBranchId);
  }

  @override
  Future<void> setActiveCartBranchId(String? branchId) async {
    if (branchId == null || branchId.trim().isEmpty) {
      await _preferences.remove(_keyActiveCartBranchId);
    } else {
      await _preferences.setString(_keyActiveCartBranchId, branchId);
    }
  }
}
