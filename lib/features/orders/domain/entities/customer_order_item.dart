/// Pure domain entity representing an item within a customer order.
class CustomerOrderItem {
  const CustomerOrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.priceAtPurchase,
    this.isUnit = false,
  });

  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double priceAtPurchase;
  final bool isUnit;

  double get totalPrice => priceAtPurchase * quantity;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerOrderItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          productId == other.productId &&
          quantity == other.quantity &&
          priceAtPurchase == other.priceAtPurchase;

  @override
  int get hashCode => Object.hash(id, productId, quantity, priceAtPurchase);
}
