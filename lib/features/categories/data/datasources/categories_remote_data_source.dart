import '../models/category_model.dart';

/// Contract for fetching store categories from the remote backend.
abstract interface class CategoriesRemoteDataSource {
  /// Calls `GET /store/categories` to retrieve the list of public categories.
  Future<List<CategoryModel>> getCategories();
}
