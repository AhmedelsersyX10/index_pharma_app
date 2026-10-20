import 'package:dio/dio.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/core/network/error_mapper.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../datasources/checkout_remote_data_source.dart';
import '../models/order_request_model.dart';

/// Implementation of [CheckoutRepository] using [CheckoutRemoteDataSource].
class CheckoutRepositoryImpl implements CheckoutRepository {
  const CheckoutRepositoryImpl({
    required CheckoutRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final CheckoutRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<Order>> createOrder(OrderRequestModel request) async {
    try {
      final orderModel = await _remoteDataSource.createOrder(request);
      return Success(orderModel.toEntity());
    } on DioException catch (e) {
      return Err(e.toFailure());
    } catch (e) {
      return Err(Unexpected(serverMessage: e.toString()));
    }
  }
}
