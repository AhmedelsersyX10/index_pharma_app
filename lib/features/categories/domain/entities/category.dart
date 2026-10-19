/// Pure domain entity representing a store category.
///
/// Strictly derived from `GET /store/categories` payload:
/// ```json
/// {
///   "id": "cmv9bxrwr0003wqgoxhdft6rb",
///   "name": "Skincare"
/// }
/// ```
class Category {
  const Category({
    required this.id,
    required this.name,
  });

  /// Unique identifier of the category.
  final String id;

  /// Display name of the category.
  final String name;

  Category copyWith({
    String? id,
    String? name,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() => 'Category(id: $id, name: $name)';
}
