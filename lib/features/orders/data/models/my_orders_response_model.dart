import '../../domain/entities/my_orders_page.dart';
import 'customer_order_model.dart';

/// Data model representing the wrapper returned by `GET /store/orders/my`.
class MyOrdersResponseModel {
  const MyOrdersResponseModel({
    required this.success,
    required this.count,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.data,
  });

  final bool success;
  final int count;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final List<CustomerOrderModel> data;

  factory MyOrdersResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] as List<dynamic>? ?? [];
    return MyOrdersResponseModel(
      success: json['success'] as bool? ?? true,
      count: (json['count'] as num?)?.toInt() ?? rawData.length,
      total: (json['total'] as num?)?.toInt() ?? rawData.length,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      data: rawData
          .whereType<Map<String, dynamic>>()
          .map((item) => CustomerOrderModel.fromJson(item))
          .toList(),
    );
  }

  MyOrdersPage toEntity() => MyOrdersPage(
        orders: data.map((e) => e.toEntity()).toList(),
        total: total,
        page: page,
        limit: limit,
        totalPages: totalPages,
      );
}
