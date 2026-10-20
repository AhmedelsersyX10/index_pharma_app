import 'package:flutter/foundation.dart';
import 'package:index_pharma/features/cart/domain/entities/cart_item.dart';

/// Sealed state representing the current status of the customer's shopping cart.
///
/// Follows strict project rules:
/// - Explicit empty / hasItems states.
/// - Scoped to a single branch.
/// - Computed prices are strictly display previews and never trusted by the server.
sealed class CartState {
  const CartState();
}

/// The cart is empty for the current branch or no branch has items in cart.
class CartEmpty extends CartState {
  const CartEmpty({this.branchId});

  /// The active branch ID associated with this empty cart, if known.
  final String? branchId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartEmpty &&
          runtimeType == other.runtimeType &&
          branchId == other.branchId;

  @override
  int get hashCode => branchId.hashCode;

  @override
  String toString() => 'CartEmpty(branchId: $branchId)';
}

/// The cart contains one or more items for a specific [branchId].
class CartHasItems extends CartState {
  const CartHasItems({
    required this.branchId,
    required this.items,
    required this.subtotal,
    required this.totalItemsCount,
    required this.totalUniqueProducts,
    this.hasRxItems = false,
    this.stockAlertMessage,
  });

  /// The single branch ID to which these cart items belong.
  final String branchId;

  /// The list of items currently in the cart.
  final List<CartItem> items;

  /// Subtotal computed solely as the sum of `product.sellingPrice * quantity`.
  final double subtotal;

  /// Total units count across all items (sum of quantities).
  final int totalItemsCount;

  /// Number of distinct products in the cart.
  final int totalUniqueProducts;

  /// Whether any item in the cart requires a doctor prescription (Rx).
  final bool hasRxItems;

  /// Optional stock adjustment warning (e.g. quantity was capped to available stock).
  final String? stockAlertMessage;

  /// Creates a copy of this state with specified fields replaced.
  CartHasItems copyWith({
    String? branchId,
    List<CartItem>? items,
    double? subtotal,
    int? totalItemsCount,
    int? totalUniqueProducts,
    bool? hasRxItems,
    String? stockAlertMessage,
    bool clearStockAlert = false,
  }) {
    return CartHasItems(
      branchId: branchId ?? this.branchId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      totalItemsCount: totalItemsCount ?? this.totalItemsCount,
      totalUniqueProducts: totalUniqueProducts ?? this.totalUniqueProducts,
      hasRxItems: hasRxItems ?? this.hasRxItems,
      stockAlertMessage: clearStockAlert
          ? null
          : (stockAlertMessage ?? this.stockAlertMessage),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartHasItems &&
          runtimeType == other.runtimeType &&
          branchId == other.branchId &&
          listEquals(items, other.items) &&
          subtotal == other.subtotal &&
          totalItemsCount == other.totalItemsCount &&
          totalUniqueProducts == other.totalUniqueProducts &&
          hasRxItems == other.hasRxItems &&
          stockAlertMessage == other.stockAlertMessage;

  @override
  int get hashCode => Object.hash(
        branchId,
        Object.hashAll(items),
        subtotal,
        totalItemsCount,
        totalUniqueProducts,
        hasRxItems,
        stockAlertMessage,
      );

  @override
  String toString() =>
      'CartHasItems(branchId: $branchId, unique: $totalUniqueProducts, totalUnits: $totalItemsCount, subtotal: $subtotal, hasRx: $hasRxItems, alert: $stockAlertMessage)';
}
