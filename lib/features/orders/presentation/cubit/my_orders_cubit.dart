import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:index_pharma/core/errors/failure_mapper.dart';
import 'package:index_pharma/core/network/api_result.dart';
import '../../domain/usecases/get_my_orders_use_case.dart';
import 'my_orders_state.dart';

/// Cubit managing state transitions for the customer My Orders screen.
class MyOrdersCubit extends Cubit<MyOrdersState> {
  MyOrdersCubit({
    required GetMyOrdersUseCase getMyOrdersUseCase,
    this.pageSize = 20,
  })  : _getMyOrdersUseCase = getMyOrdersUseCase,
        super(const MyOrdersInitial());

  final GetMyOrdersUseCase _getMyOrdersUseCase;
  final int pageSize;

  /// Retrieves initial or refreshed orders list.
  Future<void> fetchMyOrders({bool refresh = false}) async {
    final currentFilter = switch (state) {
      MyOrdersLoaded s => s.filter,
      MyOrdersEmpty s => s.filter,
      _ => OrderFilter.all,
    };

    if (refresh || state is! MyOrdersLoaded) {
      emit(const MyOrdersLoading());
    }

    final result = await _getMyOrdersUseCase(page: 1, limit: pageSize);

    switch (result) {
      case Success(:final data):
        if (data.orders.isEmpty) {
          emit(MyOrdersEmpty(filter: currentFilter));
        } else {
          emit(
            MyOrdersLoaded(
              orders: data.orders,
              page: data.page,
              totalPages: data.totalPages,
              total: data.total,
              hasReachedMax: !data.hasMore,
              filter: currentFilter,
            ),
          );
        }
      case Err(:final failure):
        emit(
          MyOrdersFailure(
            failure: failure,
            message: FailureMapper.toMessage(failure),
          ),
        );
    }
  }

  /// Loads the next page of orders when scrolling near the bottom.
  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! MyOrdersLoaded) return;
    if (currentState.isLoadingMore || currentState.hasReachedMax) return;

    emit(currentState.copyWith(isLoadingMore: true, clearLoadingMoreError: true));

    final nextPage = currentState.page + 1;
    final result = await _getMyOrdersUseCase(page: nextPage, limit: pageSize);

    switch (result) {
      case Success(:final data):
        final combined = [...currentState.orders, ...data.orders];
        emit(
          currentState.copyWith(
            orders: combined,
            page: data.page,
            totalPages: data.totalPages,
            total: data.total,
            hasReachedMax: !data.hasMore,
            isLoadingMore: false,
          ),
        );
      case Err(:final failure):
        emit(
          currentState.copyWith(
            isLoadingMore: false,
            loadingMoreError: failure,
          ),
        );
    }
  }

  /// Changes the currently active status filter tab (All, Active, Past).
  void setFilter(OrderFilter filter) {
    final currentState = state;
    if (currentState is MyOrdersLoaded) {
      emit(currentState.copyWith(filter: filter));
    } else if (currentState is MyOrdersEmpty) {
      emit(MyOrdersEmpty(filter: filter));
    }
  }
}
