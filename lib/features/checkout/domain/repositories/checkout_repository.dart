import 'package:index_pharma/core/network/api_result.dart';
import '../../data/models/order_request_model.dart';
import '../entities/order.dart';

/// Contract for checkout operations.
abstract class CheckoutRepository {
  /// Places an order via `POST /store/orders`.
  ///
  /// Returns:
  /// - [Success] containing the placed [Order] on HTTP 201.
  /// - [Err] with [Conflict] on HTTP 409 (insufficient stock / stock changed).
  /// - [Err] with [NotFound] on HTTP 404 (product unavailable).
  /// - [Err] with [Validation] on HTTP 400 (validation failure / empty cart).
  /// - [Err] with [Unauthorized] on HTTP 401 (guest / unauthenticated).
  Future<ApiResult<Order>> createOrder(OrderRequestModel request);
}
