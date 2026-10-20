import 'customer_order.dart';

/// Paginated result of customer orders.
class MyOrdersPage {
  const MyOrdersPage({
    required this.orders,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  final List<CustomerOrder> orders;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  bool get hasMore => page < totalPages;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyOrdersPage &&
          runtimeType == other.runtimeType &&
          total == other.total &&
          page == other.page &&
          limit == other.limit &&
          totalPages == other.totalPages;

  @override
  int get hashCode => Object.hash(total, page, limit, totalPages);
}
