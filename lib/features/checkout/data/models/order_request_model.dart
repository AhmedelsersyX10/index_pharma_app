/// DTO for each item in the order creation payload.
class OrderItemRequestModel {
  const OrderItemRequestModel({
    required this.productId,
    required this.quantity,
  });

  final String productId;
  final int quantity;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'quantity': quantity,
      };

  factory OrderItemRequestModel.fromJson(Map<String, dynamic> json) {
    return OrderItemRequestModel(
      productId: json['productId'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderItemRequestModel &&
          runtimeType == other.runtimeType &&
          productId == other.productId &&
          quantity == other.quantity;

  @override
  int get hashCode => Object.hash(productId, quantity);
}

/// DTO for `POST /store/orders` request body.
///
/// Follows strict API contract:
/// - No prices, subtotals, or taxes sent from client.
/// - Only boxes/packs (`isUnit` & `isSecondaryUnit` omitted).
class OrderRequestModel {
  const OrderRequestModel({
    required this.branchId,
    required this.orderItems,
    required this.deliveryAddress,
    required this.customerPhone,
    this.notes,
  });

  final String branchId;
  final List<OrderItemRequestModel> orderItems;
  final String deliveryAddress;
  final String customerPhone;
  final String? notes;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'branchId': branchId,
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
      'deliveryAddress': deliveryAddress,
      'customerPhone': customerPhone,
    };
    if (notes != null && notes!.trim().isNotEmpty) {
      map['notes'] = notes!.trim();
    }
    return map;
  }

  factory OrderRequestModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['orderItems'] as List<dynamic>? ?? [];
    return OrderRequestModel(
      branchId: json['branchId'] as String? ?? '',
      orderItems: rawItems
          .whereType<Map<String, dynamic>>()
          .map((item) => OrderItemRequestModel.fromJson(item))
          .toList(),
      deliveryAddress: json['deliveryAddress'] as String? ?? '',
      customerPhone: json['customerPhone'] as String? ?? '',
      notes: json['notes'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderRequestModel &&
          runtimeType == other.runtimeType &&
          branchId == other.branchId &&
          deliveryAddress == other.deliveryAddress &&
          customerPhone == other.customerPhone &&
          notes == other.notes;

  @override
  int get hashCode =>
      Object.hash(branchId, deliveryAddress, customerPhone, notes);
}
