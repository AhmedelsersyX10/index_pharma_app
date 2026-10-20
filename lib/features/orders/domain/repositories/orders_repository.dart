import 'package:index_pharma/core/network/api_result.dart';
import '../entities/my_orders_page.dart';

/// Contract for accessing customer orders in domain layer.
abstract class OrdersRepository {
  /// Fetches paginated orders for the authenticated customer.
  Future<ApiResult<MyOrdersPage>> getMyOrders({
    int page = 1,
    int limit = 20,
  });
}
