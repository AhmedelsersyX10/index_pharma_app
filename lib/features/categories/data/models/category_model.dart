import '../../domain/entities/category.dart';

/// Data Transfer Object representing a category from `GET /store/categories`.
///
/// Strictly handles verified schema fields:
/// - `id` (String)
/// - `name` (String)
class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
  });

  /// Creates a [CategoryModel] from a JSON map.
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
    );
  }

  /// Converts this [CategoryModel] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  /// Converts this model to a pure domain [Category] entity.
  Category toEntity() {
    return Category(
      id: id,
      name: name,
    );
  }

  /// Creates a [CategoryModel] from a domain [Category] entity.
  factory CategoryModel.fromEntity(Category entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
    );
  }
}
