import '../models/order_model.dart';
import '../models/order_request_model.dart';

/// Contract for placing orders against the remote Index Pharma Store API.
abstract class CheckoutRemoteDataSource {
  /// Submits an order request to `POST /store/orders`.
  ///
  /// Throws [DioException] on network or HTTP error status codes.
  Future<OrderModel> createOrder(OrderRequestModel request);
}
