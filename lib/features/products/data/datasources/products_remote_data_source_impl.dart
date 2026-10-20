import 'package:dio/dio.dart';
import '../models/product_model.dart';
import '../models/products_page_model.dart';
import 'products_remote_data_source.dart';

/// Implementation of [ProductsRemoteDataSource] using [Dio].
class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  const ProductsRemoteDataSourceImpl({
    required Dio dio,
  }) : _dio = dio;

  final Dio _dio;

  @override
  Future<ProductsPageModel> getProducts({
    required String branchId,
    int page = 1,
    int limit = 20,
    String? keyword,
    String? category,
  }) async {
    final clampedLimit = limit.clamp(1, 100);
    final queryParameters = <String, dynamic>{
      'branchId': branchId,
      'page': page,
      'limit': clampedLimit,
    };

    if (keyword != null && keyword.trim().isNotEmpty) {
      queryParameters['keyword'] = keyword.trim();
    }
    if (category != null && category.trim().isNotEmpty) {
      queryParameters['category'] = category.trim();
    }

    final response = await _dio.get<dynamic>(
      '/store/products',
      queryParameters: queryParameters,
    );

    final data = response.data;
    if (data is Map) {
      return ProductsPageModel.fromJson(Map<String, dynamic>.from(data));
    }

    throw const FormatException(
      'Invalid or corrupted products payload from server',
    );
  }

  @override
  Future<ProductModel> getProductById({
    required String productId,
    required String branchId,
  }) async {
    final cleanBranchId = branchId.trim();
    if (cleanBranchId.isEmpty) {
      throw ArgumentError('branchId is required and cannot be empty');
    }

    final response = await _dio.get<dynamic>(
      '/store/products/$productId',
      queryParameters: {'branchId': cleanBranchId},
    );

    final body = response.data;
    if (body is Map) {
      final data = body['data'];
      if (data is Map) {
        return ProductModel.fromJson(Map<String, dynamic>.from(data));
      }
      if (body['id'] != null) {
        return ProductModel.fromJson(Map<String, dynamic>.from(body));
      }
    }

    throw const FormatException(
      'Invalid or corrupted product details payload from server',
    );
  }
}
