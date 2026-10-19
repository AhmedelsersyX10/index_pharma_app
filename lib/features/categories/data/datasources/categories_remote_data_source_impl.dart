import 'package:dio/dio.dart';
import '../models/category_model.dart';
import 'categories_remote_data_source.dart';

/// Implementation of [CategoriesRemoteDataSource] using [Dio].
class CategoriesRemoteDataSourceImpl implements CategoriesRemoteDataSource {
  const CategoriesRemoteDataSourceImpl({
    required Dio dio,
  }) : _dio = dio;

  final Dio _dio;

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await _dio.get<dynamic>('/store/categories');
    final data = response.data;

    if (data is Map) {
      final categoriesData = data['data'];
      if (categoriesData is List) {
        return categoriesData
            .whereType<Map>()
            .map(
              (item) => CategoryModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }
    } else if (data is List) {
      return data
          .whereType<Map>()
          .map(
            (item) => CategoryModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    throw const FormatException(
      'Invalid or missing categories array in response',
    );
  }
}
