import 'package:dio/dio.dart';
import '../models/my_orders_response_model.dart';
import 'orders_remote_data_source.dart';

/// Implementation of [OrdersRemoteDataSource] using [Dio].
class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  const OrdersRemoteDataSourceImpl({
    required Dio dio,
  }) : _dio = dio;

  final Dio _dio;

  @override
  Future<MyOrdersResponseModel> getMyOrders({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get<dynamic>(
      '/store/orders/my',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return MyOrdersResponseModel.fromJson(data);
    } else if (data is Map) {
      return MyOrdersResponseModel.fromJson(Map<String, dynamic>.from(data));
    }

    throw const FormatException('Invalid orders response format from server');
  }
}
