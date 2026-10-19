import 'package:index_pharma/features/categories/data/models/category_model.dart';
import '../../domain/entities/product.dart';

/// Data Transfer Object representing a product from `GET /store/products`.
///
/// Strictly mirrors the verified server payload schema:
/// - `id` (String)
/// - `name` (String)
/// - `scientificName` (String?)
/// - `barcode` (String?)
/// - `description` (String?)
/// - `image` (String?)
/// - `sellingPrice` (double)
/// - `stockQuantity` (int)
/// - `looseQuantity` (int)
/// - `expiryDate` (String?)
/// - `requiresPrescription` (bool)
/// - `unit` (String?)
/// - `category` (CategoryModel?)
/// - `branchId` (String)
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    super.scientificName,
    super.barcode,
    super.description,
    super.image,
    required super.sellingPrice,
    required super.stockQuantity,
    super.looseQuantity = 0,
    super.expiryDate,
    super.requiresPrescription = false,
    super.unit,
    super.category,
    required super.branchId,
  });

  /// Creates a [ProductModel] from a JSON map.
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    CategoryModel? parsedCategory;
    final categoryJson = json['category'];
    if (categoryJson is Map<String, dynamic>) {
      parsedCategory = CategoryModel.fromJson(categoryJson);
    } else if (categoryJson is Map) {
      parsedCategory =
          CategoryModel.fromJson(Map<String, dynamic>.from(categoryJson));
    }

    final sellingPriceRaw = json['sellingPrice'];
    final sellingPrice = sellingPriceRaw is num
        ? sellingPriceRaw.toDouble()
        : double.tryParse(sellingPriceRaw?.toString() ?? '0') ?? 0.0;

    final stockQuantityRaw = json['stockQuantity'];
    final stockQuantity = stockQuantityRaw is num
        ? stockQuantityRaw.toInt()
        : int.tryParse(stockQuantityRaw?.toString() ?? '0') ?? 0;

    final looseQuantityRaw = json['looseQuantity'];
    final looseQuantity = looseQuantityRaw is num
        ? looseQuantityRaw.toInt()
        : int.tryParse(looseQuantityRaw?.toString() ?? '0') ?? 0;

    return ProductModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      scientificName: json['scientificName']?.toString(),
      barcode: json['barcode']?.toString(),
      description: json['description']?.toString(),
      image: json['image']?.toString(),
      sellingPrice: sellingPrice,
      stockQuantity: stockQuantity,
      looseQuantity: looseQuantity,
      expiryDate: json['expiryDate']?.toString(),
      requiresPrescription: json['requiresPrescription'] == true,
      unit: json['unit']?.toString(),
      category: parsedCategory,
      branchId: (json['branchId'] ?? '').toString(),
    );
  }

  /// Converts this [ProductModel] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (scientificName != null) 'scientificName': scientificName,
      if (barcode != null) 'barcode': barcode,
      if (description != null) 'description': description,
      if (image != null) 'image': image,
      'sellingPrice': sellingPrice,
      'stockQuantity': stockQuantity,
      'looseQuantity': looseQuantity,
      if (expiryDate != null) 'expiryDate': expiryDate,
      'requiresPrescription': requiresPrescription,
      if (unit != null) 'unit': unit,
      if (category != null)
        'category': {
          'id': category!.id,
          'name': category!.name,
        },
      'branchId': branchId,
    };
  }

  /// Converts this model to a pure domain [Product] entity.
  Product toEntity() {
    return Product(
      id: id,
      name: name,
      scientificName: scientificName,
      barcode: barcode,
      description: description,
      image: image,
      sellingPrice: sellingPrice,
      stockQuantity: stockQuantity,
      looseQuantity: looseQuantity,
      expiryDate: expiryDate,
      requiresPrescription: requiresPrescription,
      unit: unit,
      category: category,
      branchId: branchId,
    );
  }
}
