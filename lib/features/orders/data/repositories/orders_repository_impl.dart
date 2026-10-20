import 'package:dio/dio.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/core/network/error_mapper.dart';
import '../../domain/entities/my_orders_page.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_data_source.dart';

/// Implementation of [OrdersRepository] using [OrdersRemoteDataSource].
class OrdersRepositoryImpl implements OrdersRepository {
  const OrdersRepositoryImpl({
    required OrdersRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final OrdersRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<MyOrdersPage>> getMyOrders({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final responseModel = await _remoteDataSource.getMyOrders(
        page: page,
        limit: limit,
      );
      return Success(responseModel.toEntity());
    } on DioException catch (e) {
      return Err(e.toFailure());
    } catch (e) {
      return Err(Unexpected(serverMessage: e.toString()));
    }
  }
}
