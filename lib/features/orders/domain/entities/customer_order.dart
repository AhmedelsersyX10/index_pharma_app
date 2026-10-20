import 'customer_order_item.dart';
import 'order_status.dart';

/// Pure domain entity representing a customer order returned by `GET /store/orders/my`.
class CustomerOrder {
  const CustomerOrder({
    required this.id,
    required this.orderNumber,
    required this.subtotal,
    this.discountType,
    this.discountValue = 0,
    required this.totalAmount,
    this.paidAmount = 0,
    this.dueAmount = 0,
    this.changeAmount = 0,
    required this.orderType,
    required this.status,
    required this.paymentMethod,
    required this.deliveryAddress,
    required this.customerPhone,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    required this.items,
  });

  final String id;
  final String orderNumber;
  final double subtotal;
  final String? discountType;
  final double discountValue;
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;
  final double changeAmount;
  final String orderType;
  final String status;
  final String paymentMethod;
  final String deliveryAddress;
  final String customerPhone;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<CustomerOrderItem> items;

  /// Parsed type-safe status representation.
  OrderStatus get statusEnum => OrderStatus.fromString(status);

  /// Total count of product units in this order.
  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerOrder &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          orderNumber == other.orderNumber;

  @override
  int get hashCode => Object.hash(id, orderNumber);
}
