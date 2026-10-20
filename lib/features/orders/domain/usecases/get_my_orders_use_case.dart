import 'package:index_pharma/core/network/api_result.dart';
import '../entities/my_orders_page.dart';
import '../repositories/orders_repository.dart';

/// Use case for retrieving paginated customer orders.
class GetMyOrdersUseCase {
  const GetMyOrdersUseCase({
    required OrdersRepository repository,
  }) : _repository = repository;

  final OrdersRepository _repository;

  Future<ApiResult<MyOrdersPage>> call({
    int page = 1,
    int limit = 20,
  }) {
    return _repository.getMyOrders(page: page, limit: limit);
  }
}
