import 'order_item.dart';

/// Pure domain entity representing a placed customer order.
class Order {
  const Order({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.branchId,
    required this.subtotal,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueAmount,
    required this.changeAmount,
    required this.orderType,
    required this.status,
    required this.paymentMethod,
    required this.deliveryAddress,
    required this.customerPhone,
    this.notes,
    required this.createdAt,
    required this.items,
  });

  final String id;
  final String orderNumber;
  final String customerId;
  final String branchId;
  final double subtotal;
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
  final List<OrderItem> items;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Order &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          orderNumber == other.orderNumber;

  @override
  int get hashCode => Object.hash(id, orderNumber);
}
