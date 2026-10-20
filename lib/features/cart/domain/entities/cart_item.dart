import 'package:index_pharma/features/products/domain/entities/product.dart';

/// Pure domain entity representing an item inside the shopping cart.
///
/// Follows Clean Architecture:
/// - Wraps the domain [Product] and selected [quantity].
/// - [lineTotal] is dynamically computed strictly from [Product.sellingPrice] * [quantity].
/// - The server determines final billing totals upon order placement.
class CartItem {
  const CartItem({
    required this.product,
    required this.quantity,
  }) : assert(quantity >= 1, 'Quantity must be at least 1');

  /// The product item in the cart.
  final Product product;

  /// The requested quantity (clamped to available [Product.stockQuantity]).
  final int quantity;

  /// Computed display line total for the item.
  double get lineTotal => product.sellingPrice * quantity;

  /// Returns a copy of this cart item with modified properties.
  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem &&
          runtimeType == other.runtimeType &&
          product == other.product &&
          quantity == other.quantity;

  @override
  int get hashCode => Object.hash(product, quantity);

  @override
  String toString() =>
      'CartItem(product: ${product.name}, quantity: $quantity, lineTotal: $lineTotal)';
}
