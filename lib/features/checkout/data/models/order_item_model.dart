import '../../domain/entities/order_item.dart';

/// Data model representing an item in the order response.
class OrderItemModel {
  const OrderItemModel({
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

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String? ?? '',
      orderId: json['orderId'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      priceAtPurchase: (json['priceAtPurchase'] as num?)?.toDouble() ?? 0.0,
      isUnit: json['isUnit'] as bool? ?? false,
      isSecondaryUnit: json['isSecondaryUnit'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderId': orderId,
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'priceAtPurchase': priceAtPurchase,
        'isUnit': isUnit,
        'isSecondaryUnit': isSecondaryUnit,
      };

  OrderItem toEntity() => OrderItem(
        id: id,
        orderId: orderId,
        productId: productId,
        productName: productName,
        quantity: quantity,
        priceAtPurchase: priceAtPurchase,
        isUnit: isUnit,
        isSecondaryUnit: isSecondaryUnit,
      );
}
