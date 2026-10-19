import 'package:dio/dio.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/core/network/error_mapper.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/categories_repository.dart';
import '../datasources/categories_remote_data_source.dart';

/// Data layer implementation of [CategoriesRepository].
///
/// Fetches categories from [CategoriesRemoteDataSource], maps them to domain
/// entities, and converts network exceptions to domain [Failure] types.
class CategoriesRepositoryImpl implements CategoriesRepository {
  const CategoriesRepositoryImpl({
    required CategoriesRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final CategoriesRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<List<Category>>> getCategories() async {
    try {
      final models = await _remoteDataSource.getCategories();
      final entities = models.map((model) => model.toEntity()).toList();
      return Success(entities);
    } on DioException catch (e) {
      return Err(e.toFailure());
    } catch (e) {
      return Err(Unexpected(serverMessage: e.toString()));
    }
  }
}
