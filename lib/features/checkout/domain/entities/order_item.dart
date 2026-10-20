/// Pure domain entity representing an individual item within a placed order.
class OrderItem {
  const OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.priceAtPurchase,
    this.isUnit = false,
    this.isSecondaryUnit = false,
  });

  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final int quantity;
  final double priceAtPurchase;
  final bool isUnit;
  final bool isSecondaryUnit;

  double get lineTotal => priceAtPurchase * quantity;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          productId == other.productId &&
          quantity == other.quantity;

  @override
  int get hashCode => Object.hash(id, productId, quantity);
}
