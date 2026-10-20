import '../../domain/entities/order.dart';
import 'order_item_model.dart';

/// Data model representing the order returned in `POST /store/orders` response.
class OrderModel {
  const OrderModel({
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
  final List<OrderItemModel> items;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // If wrapped in {"success": true, "data": {...}}, unwrap it.
    final payload = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    final rawItems = payload['items'] as List<dynamic>? ?? [];
    final parsedCreatedAt = payload['createdAt'] != null
        ? DateTime.tryParse(payload['createdAt'].toString()) ?? DateTime.now()
        : DateTime.now();

    return OrderModel(
      id: payload['id'] as String? ?? '',
      orderNumber: payload['orderNumber'] as String? ?? '',
      customerId: payload['customerId'] as String? ?? '',
      branchId: payload['branchId'] as String? ?? '',
      subtotal: (payload['subtotal'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (payload['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (payload['paidAmount'] as num?)?.toDouble() ?? 0.0,
      dueAmount: (payload['dueAmount'] as num?)?.toDouble() ?? 0.0,
      changeAmount: (payload['changeAmount'] as num?)?.toDouble() ?? 0.0,
      orderType: payload['orderType'] as String? ?? 'ONLINE',
      status: payload['status'] as String? ?? 'pending',
      paymentMethod: payload['paymentMethod'] as String? ?? 'cash',
      deliveryAddress: payload['deliveryAddress'] as String? ?? '',
      customerPhone: payload['customerPhone'] as String? ?? '',
      notes: payload['notes'] as String?,
      createdAt: parsedCreatedAt,
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map((item) => OrderItemModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderNumber': orderNumber,
        'customerId': customerId,
        'branchId': branchId,
        'subtotal': subtotal,
        'totalAmount': totalAmount,
        'paidAmount': paidAmount,
        'dueAmount': dueAmount,
        'changeAmount': changeAmount,
        'orderType': orderType,
        'status': status,
        'paymentMethod': paymentMethod,
        'deliveryAddress': deliveryAddress,
        'customerPhone': customerPhone,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
      };

  Order toEntity() => Order(
        id: id,
        orderNumber: orderNumber,
        customerId: customerId,
        branchId: branchId,
        subtotal: subtotal,
        totalAmount: totalAmount,
        paidAmount: paidAmount,
        dueAmount: dueAmount,
        changeAmount: changeAmount,
        orderType: orderType,
        status: status,
        paymentMethod: paymentMethod,
        deliveryAddress: deliveryAddress,
        customerPhone: customerPhone,
        notes: notes,
        createdAt: createdAt,
        items: items.map((e) => e.toEntity()).toList(),
      );
}
