import 'package:index_pharma/core/network/api_result.dart';
import '../entities/category.dart';

/// Domain contract for managing store categories.
abstract interface class CategoriesRepository {
  /// Fetches public categories from the backend.
  Future<ApiResult<List<Category>>> getCategories();
}
