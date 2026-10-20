import '../../domain/entities/customer_order.dart';
import 'customer_order_item_model.dart';

/// Data model representing a customer order in `GET /store/orders/my`.
class CustomerOrderModel {
  const CustomerOrderModel({
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
  final List<CustomerOrderItemModel> items;

  factory CustomerOrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final parsedCreatedAt = json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
        : DateTime.now();
    final parsedUpdatedAt = json['updatedAt'] != null
        ? DateTime.tryParse(json['updatedAt'].toString())
        : null;

    return CustomerOrderModel(
      id: json['id'] as String? ?? '',
      orderNumber: json['orderNumber'] as String? ?? '',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discountType: json['discountType'] as String?,
      discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      dueAmount: (json['dueAmount'] as num?)?.toDouble() ?? 0.0,
      changeAmount: (json['changeAmount'] as num?)?.toDouble() ?? 0.0,
      orderType: json['orderType'] as String? ?? 'ONLINE',
      status: json['status'] as String? ?? 'pending',
      paymentMethod: json['paymentMethod'] as String? ?? 'cash',
      deliveryAddress: json['deliveryAddress'] as String? ?? '',
      customerPhone: json['customerPhone'] as String? ?? '',
      notes: json['notes'] as String?,
      createdAt: parsedCreatedAt,
      updatedAt: parsedUpdatedAt,
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map((item) => CustomerOrderItemModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderNumber': orderNumber,
        'subtotal': subtotal,
        if (discountType != null) 'discountType': discountType,
        'discountValue': discountValue,
        'totalAmount': totalAmount,
        'paidAmount': paidAmount,
        'dueAmount': dueAmount,
        'changeAmount': changeAmount,
        'orderType': orderType,
        'status': status,
        'paymentMethod': paymentMethod,
        'deliveryAddress': deliveryAddress,
        'customerPhone': customerPhone,
        if (notes != null) 'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
      };

  CustomerOrder toEntity() => CustomerOrder(
        id: id,
        orderNumber: orderNumber,
        subtotal: subtotal,
        discountType: discountType,
        discountValue: discountValue,
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
        updatedAt: updatedAt,
        items: items.map((e) => e.toEntity()).toList(),
      );
}
