import '../models/my_orders_response_model.dart';

/// Contract for fetching customer orders over HTTP.
abstract class OrdersRemoteDataSource {
  /// Fetches paginated customer orders from `GET /store/orders/my`.
  Future<MyOrdersResponseModel> getMyOrders({
    int page = 1,
    int limit = 20,
  });
}
