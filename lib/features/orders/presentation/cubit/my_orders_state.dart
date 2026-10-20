import 'package:index_pharma/core/errors/failure.dart';
import '../../domain/entities/customer_order.dart';

/// Available filter categories on the customer orders screen (Stitch C4).
enum OrderFilter {
  all,
  active,
  past;

  String get translationKey {
    switch (this) {
      case OrderFilter.all:
        return 'orders.filter_all';
      case OrderFilter.active:
        return 'orders.filter_active';
      case OrderFilter.past:
        return 'orders.filter_past';
    }
  }
}

/// Sealed state hierarchy for the My Orders feature.
sealed class MyOrdersState {
  const MyOrdersState();
}

/// Initial state before any orders are requested.
final class MyOrdersInitial extends MyOrdersState {
  const MyOrdersInitial();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyOrdersInitial && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Loading state emitted while the first page of orders is being loaded.
final class MyOrdersLoading extends MyOrdersState {
  const MyOrdersLoading();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyOrdersLoading && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// State emitted when the server returns 0 orders for the customer.
final class MyOrdersEmpty extends MyOrdersState {
  const MyOrdersEmpty({
    this.filter = OrderFilter.all,
  });

  final OrderFilter filter;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyOrdersEmpty &&
          runtimeType == other.runtimeType &&
          filter == other.filter;

  @override
  int get hashCode => Object.hash(runtimeType, filter);
}

/// Loaded state containing orders list, pagination metadata, and active filter.
final class MyOrdersLoaded extends MyOrdersState {
  const MyOrdersLoaded({
    required this.orders,
    required this.page,
    required this.totalPages,
    required this.total,
    required this.hasReachedMax,
    this.isLoadingMore = false,
    this.loadingMoreError,
    this.filter = OrderFilter.all,
  });

  final List<CustomerOrder> orders;
  final int page;
  final int totalPages;
  final int total;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final Failure? loadingMoreError;
  final OrderFilter filter;

  /// Returns orders filtered by the currently active filter pill.
  List<CustomerOrder> get filteredOrders {
    switch (filter) {
      case OrderFilter.all:
        return orders;
      case OrderFilter.active:
        return orders.where((order) => order.statusEnum.isActive).toList();
      case OrderFilter.past:
        return orders.where((order) => order.statusEnum.isPast).toList();
    }
  }

  int get countAll => orders.length;
  int get countActive => orders.where((o) => o.statusEnum.isActive).length;
  int get countPast => orders.where((o) => o.statusEnum.isPast).length;

  MyOrdersLoaded copyWith({
    List<CustomerOrder>? orders,
    int? page,
    int? totalPages,
    int? total,
    bool? hasReachedMax,
    bool? isLoadingMore,
    Failure? loadingMoreError,
    bool clearLoadingMoreError = false,
    OrderFilter? filter,
  }) {
    return MyOrdersLoaded(
      orders: orders ?? this.orders,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      total: total ?? this.total,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingMoreError: clearLoadingMoreError
          ? null
          : (loadingMoreError ?? this.loadingMoreError),
      filter: filter ?? this.filter,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyOrdersLoaded &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          totalPages == other.totalPages &&
          total == other.total &&
          hasReachedMax == other.hasReachedMax &&
          isLoadingMore == other.isLoadingMore &&
          filter == other.filter &&
          orders.length == other.orders.length;

  @override
  int get hashCode => Object.hash(
        runtimeType,
        page,
        totalPages,
        total,
        hasReachedMax,
        isLoadingMore,
        filter,
        orders.length,
      );
}

/// State emitted when an error occurs while fetching orders.
final class MyOrdersFailure extends MyOrdersState {
  const MyOrdersFailure({
    required this.failure,
    this.message,
  });

  final Failure failure;
  final String? message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyOrdersFailure &&
          runtimeType == other.runtimeType &&
          failure == other.failure &&
          message == other.message;

  @override
  int get hashCode => Object.hash(runtimeType, failure, message);
}
