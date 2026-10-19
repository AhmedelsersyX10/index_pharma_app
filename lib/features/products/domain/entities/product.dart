import 'package:index_pharma/features/categories/domain/entities/category.dart';

/// Pure domain entity representing a store product.
///
/// Strictly derived from `GET /store/products` payload:
/// ```json
/// {
///   "id": "p01f8a22-1118-4089-9e8c-669a6e118999",
///   "name": "Hydrating Cream 50ml",
///   "scientificName": "Hyaluronic Acid",
///   "barcode": "6221000000028",
///   "description": "Daily moisturizing cream for dry and sensitive skin",
///   "image": null,
///   "sellingPrice": 130,
///   "stockQuantity": 30,
///   "looseQuantity": 0,
///   "expiryDate": "2028-06-30T00:00:00.000Z",
///   "requiresPrescription": false,
///   "unit": "قطعة",
///   "category": {
///     "id": "c10f8a91-4418-4089-9e8c-779a6e118902",
///     "name": "Skincare"
///   },
///   "branchId": "b18f3a22-3118-4089-9e8c-529a6e118901"
/// }
/// ```
class Product {
  const Product({
    required this.id,
    required this.name,
    this.scientificName,
    this.barcode,
    this.description,
    this.image,
    required this.sellingPrice,
    required this.stockQuantity,
    this.looseQuantity = 0,
    this.expiryDate,
    this.requiresPrescription = false,
    this.unit,
    this.category,
    required this.branchId,
  });

  /// Unique identifier of the product.
  final String id;

  /// Commercial display name of the product.
  final String name;

  /// Active pharmaceutical ingredient or scientific name.
  final String? scientificName;

  /// Barcode number for physical scanning.
  final String? barcode;

  /// Description and therapeutic usage details.
  final String? description;

  /// Relative image path on the server origin.
  final String? image;

  /// Mandatory retail selling price determined exclusively by the server.
  final double sellingPrice;

  /// Current available package inventory count.
  final int stockQuantity;

  /// Available loose quantity count (default 0).
  final int looseQuantity;

  /// Batch expiration ISO8601 date string.
  final String? expiryDate;

  /// Whether dispensing this medication legally requires a verified prescription (Rx).
  final bool requiresPrescription;

  /// Unit of measure (e.g., 'قطعة', 'علبة').
  final String? unit;

  /// Associated therapeutic category, if assigned.
  final Category? category;

  /// Branch ID this stock quantity belongs to.
  final String branchId;

  /// Creates a copy of this product with specified fields replaced.
  Product copyWith({
    String? id,
    String? name,
    String? scientificName,
    String? barcode,
    String? description,
    String? image,
    double? sellingPrice,
    int? stockQuantity,
    int? looseQuantity,
    String? expiryDate,
    bool? requiresPrescription,
    String? unit,
    Category? category,
    String? branchId,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      scientificName: scientificName ?? this.scientificName,
      barcode: barcode ?? this.barcode,
      description: description ?? this.description,
      image: image ?? this.image,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      looseQuantity: looseQuantity ?? this.looseQuantity,
      expiryDate: expiryDate ?? this.expiryDate,
      requiresPrescription: requiresPrescription ?? this.requiresPrescription,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      branchId: branchId ?? this.branchId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          scientificName == other.scientificName &&
          barcode == other.barcode &&
          description == other.description &&
          image == other.image &&
          sellingPrice == other.sellingPrice &&
          stockQuantity == other.stockQuantity &&
          looseQuantity == other.looseQuantity &&
          expiryDate == other.expiryDate &&
          requiresPrescription == other.requiresPrescription &&
          unit == other.unit &&
          category == other.category &&
          branchId == other.branchId;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        scientificName,
        barcode,
        description,
        image,
        sellingPrice,
        stockQuantity,
        looseQuantity,
        expiryDate,
        requiresPrescription,
        unit,
        category,
        branchId,
      );

  @override
  String toString() =>
      'Product(id: $id, name: $name, scientificName: $scientificName, barcode: $barcode, sellingPrice: $sellingPrice, stockQuantity: $stockQuantity, requiresPrescription: $requiresPrescription, branchId: $branchId)';
}
