import 'package:index_pharma/features/cart/domain/entities/cart_item.dart';
import 'package:index_pharma/features/products/data/models/product_model.dart';

/// Data Transfer Object representing a cart item for local persistence.
///
/// Converts [CartItem] domain entity to and from JSON format using [ProductModel].
class CartItemModel extends CartItem {
  const CartItemModel({
    required super.product,
    required super.quantity,
  });

  /// Creates a [CartItemModel] from a JSON map.
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final productJson = json['product'] as Map<String, dynamic>;
    final productModel = ProductModel.fromJson(productJson);
    final quantity = (json['quantity'] as num?)?.toInt() ?? 1;

    return CartItemModel(
      product: productModel.toEntity(),
      quantity: quantity < 1 ? 1 : quantity,
    );
  }

  /// Creates a [CartItemModel] from a domain [CartItem] entity.
  factory CartItemModel.fromEntity(CartItem entity) {
    return CartItemModel(
      product: entity.product,
      quantity: entity.quantity,
    );
  }

  /// Converts this model into a JSON map.
  Map<String, dynamic> toJson() {
    final productModel = product is ProductModel
        ? product as ProductModel
        : ProductModel(
            id: product.id,
            name: product.name,
            scientificName: product.scientificName,
            barcode: product.barcode,
            description: product.description,
            image: product.image,
            sellingPrice: product.sellingPrice,
            stockQuantity: product.stockQuantity,
            looseQuantity: product.looseQuantity,
            expiryDate: product.expiryDate,
            requiresPrescription: product.requiresPrescription,
            unit: product.unit,
            category: product.category,
            branchId: product.branchId,
          );

    return {
      'product': productModel.toJson(),
      'quantity': quantity,
    };
  }

  /// Converts this model to a pure domain [CartItem] entity.
  CartItem toEntity() {
    return CartItem(
      product: product,
      quantity: quantity,
    );
  }
}
