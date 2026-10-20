import '../../domain/entities/customer_order_item.dart';

/// Data model representing an item in `GET /store/orders/my`.
class CustomerOrderItemModel {
  const CustomerOrderItemModel({
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

  factory CustomerOrderItemModel.fromJson(Map<String, dynamic> json) {
    return CustomerOrderItemModel(
      id: json['id'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      priceAtPurchase: (json['priceAtPurchase'] as num?)?.toDouble() ?? 0.0,
      isUnit: json['isUnit'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'priceAtPurchase': priceAtPurchase,
        'isUnit': isUnit,
      };

  CustomerOrderItem toEntity() => CustomerOrderItem(
        id: id,
        productId: productId,
        productName: productName,
        quantity: quantity,
        priceAtPurchase: priceAtPurchase,
        isUnit: isUnit,
      );
}
