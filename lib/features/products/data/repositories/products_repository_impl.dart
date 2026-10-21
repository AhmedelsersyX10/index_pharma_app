import 'package:dio/dio.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/core/network/error_mapper.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/products_page.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_remote_data_source.dart';

/// Data layer implementation of [ProductsRepository].
class ProductsRepositoryImpl implements ProductsRepository {
  const ProductsRepositoryImpl({
    required ProductsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ProductsRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<ProductsPage>> getProducts({
    required String branchId,
    int page = 1,
    int limit = 20,
    String? keyword,
    String? category,
  }) async {
    try {
      final pageModel = await _remoteDataSource.getProducts(
        branchId: branchId,
        page: page,
        limit: limit,
        keyword: keyword,
        category: category,
      );
      return Success(pageModel.toEntity());
    } on DioException catch (e) {
      return Err(e.toFailure());
    } catch (e) {
      return Err(Unexpected(serverMessage: e.toString()));
    }
  }

  @override
  Future<ApiResult<Product>> getProductDetails({
    required String productId,
    required String branchId,
  }) async {
    final cleanBranchId = branchId.trim();
    if (cleanBranchId.isEmpty) {
      return const Err(
        Validation(
          serverMessage: 'branch_id_required',
        ),
      );
    }

    final cleanProductId = productId.trim();
    if (cleanProductId.isEmpty) {
      return const Err(
        Validation(
          serverMessage: 'product_id_required',
        ),
      );
    }

    try {
      final productModel = await _remoteDataSource.getProductById(
        productId: cleanProductId,
        branchId: cleanBranchId,
      );
      return Success(productModel.toEntity());
    } on DioException catch (e) {
      return Err(e.toFailure());
    } catch (e) {
      return Err(Unexpected(serverMessage: e.toString()));
    }
  }
}
