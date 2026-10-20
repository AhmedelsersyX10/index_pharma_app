import 'package:dio/dio.dart';
import '../models/order_model.dart';
import '../models/order_request_model.dart';
import 'checkout_remote_data_source.dart';

/// Implementation of [CheckoutRemoteDataSource] using [Dio].
class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  const CheckoutRemoteDataSourceImpl({
    required Dio dio,
  }) : _dio = dio;

  final Dio _dio;

  @override
  Future<OrderModel> createOrder(OrderRequestModel request) async {
    final response = await _dio.post<dynamic>(
      '/store/orders',
      data: request.toJson(),
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return OrderModel.fromJson(data);
    } else if (data is Map) {
      return OrderModel.fromJson(Map<String, dynamic>.from(data));
    }

    throw const FormatException(
      'Invalid order creation response format from server',
    );
  }
}
