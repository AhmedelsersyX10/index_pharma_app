import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/features/orders/domain/entities/customer_order.dart';
import 'package:index_pharma/features/orders/domain/entities/customer_order_item.dart';
import 'package:index_pharma/features/orders/domain/entities/my_orders_page.dart';
import 'package:index_pharma/features/orders/domain/repositories/orders_repository.dart';
import 'package:index_pharma/features/orders/domain/usecases/get_my_orders_use_case.dart';
import 'package:index_pharma/features/orders/presentation/cubit/my_orders_cubit.dart';
import 'package:index_pharma/features/orders/presentation/cubit/my_orders_state.dart';

class FakeOrdersRepository implements OrdersRepository {
  ApiResult<MyOrdersPage>? resultToReturn;
  int? requestedPage;
  int? requestedLimit;
  int callCount = 0;

  @override
  Future<ApiResult<MyOrdersPage>> getMyOrders({
    int page = 1,
    int limit = 20,
  }) async {
    callCount++;
    requestedPage = page;
    requestedLimit = limit;
    return resultToReturn!;
  }
}

void main() {
  group('MyOrdersCubit Tests', () {
    late FakeOrdersRepository fakeRepository;
    late GetMyOrdersUseCase useCase;
    late MyOrdersCubit cubit;

    setUp(() {
      fakeRepository = FakeOrdersRepository();
      useCase = GetMyOrdersUseCase(repository: fakeRepository);
      cubit = MyOrdersCubit(getMyOrdersUseCase: useCase, pageSize: 2);
    });

    tearDown(() {
      cubit.close();
    });

    final testOrder1 = CustomerOrder(
      id: 'ord-1',
      orderNumber: 'ONL-001',
      subtotal: 100,
      totalAmount: 100,
      orderType: 'ONLINE',
      status: 'pending',
      paymentMethod: 'cash',
      deliveryAddress: 'Cairo',
      customerPhone: '01012345678',
      createdAt: DateTime(2026, 10, 18),
      items: const [
        CustomerOrderItem(
          id: 'it-1',
          productId: 'p-1',
          productName: 'Panadol',
          quantity: 2,
          priceAtPurchase: 50,
        ),
      ],
    );

    final testOrder2 = CustomerOrder(
      id: 'ord-2',
      orderNumber: 'ONL-002',
      subtotal: 200,
      totalAmount: 200,
      orderType: 'ONLINE',
      status: 'delivered',
      paymentMethod: 'cash',
      deliveryAddress: 'Giza',
      customerPhone: '01012345678',
      createdAt: DateTime(2026, 10, 19),
      items: const [
        CustomerOrderItem(
          id: 'it-2',
          productId: 'p-2',
          productName: 'C-Retard',
          quantity: 1,
          priceAtPurchase: 200,
        ),
      ],
    );

    test('initial state is MyOrdersInitial', () {
      expect(cubit.state, const MyOrdersInitial());
    });

    test('fetchMyOrders emits [MyOrdersLoading, MyOrdersLoaded] on success',
        () async {
      fakeRepository.resultToReturn = Success(
        MyOrdersPage(
          orders: [testOrder1, testOrder2],
          total: 2,
          page: 1,
          limit: 2,
          totalPages: 1,
        ),
      );

      final states = <MyOrdersState>[];
      cubit.stream.listen(states.add);

      await cubit.fetchMyOrders();
      await pumpEventQueue();

      expect(states.length, 2);
      expect(states[0], const MyOrdersLoading());
      expect(states[1], isA<MyOrdersLoaded>());

      final loadedState = states[1] as MyOrdersLoaded;
      expect(loadedState.orders.length, 2);
      expect(loadedState.total, 2);
      expect(loadedState.hasReachedMax, isTrue);
      expect(loadedState.filter, OrderFilter.all);
    });

    test('fetchMyOrders emits [MyOrdersLoading, MyOrdersEmpty] when orders list is empty',
        () async {
      fakeRepository.resultToReturn = const Success(
        MyOrdersPage(
          orders: [],
          total: 0,
          page: 1,
          limit: 2,
          totalPages: 0,
        ),
      );

      final states = <MyOrdersState>[];
      cubit.stream.listen(states.add);

      await cubit.fetchMyOrders();
      await pumpEventQueue();

      expect(states.length, 2);
      expect(states[0], const MyOrdersLoading());
      expect(states[1], isA<MyOrdersEmpty>());
    });

    test('fetchMyOrders emits [MyOrdersLoading, MyOrdersFailure] on error',
        () async {
      fakeRepository.resultToReturn = const Err(
        Unauthorized(serverMessage: 'انتهت الجلسة'),
      );

      final states = <MyOrdersState>[];
      cubit.stream.listen(states.add);

      await cubit.fetchMyOrders();
      await pumpEventQueue();

      expect(states.length, 2);
      expect(states[0], const MyOrdersLoading());
      expect(states[1], isA<MyOrdersFailure>());
      expect(
        (states[1] as MyOrdersFailure).message,
        AppLocaleKeys.errorUnauthorized.tr(),
      );
    });

    test('loadMore appends orders on successful pagination call', () async {
      // First page
      fakeRepository.resultToReturn = Success(
        MyOrdersPage(
          orders: [testOrder1],
          total: 2,
          page: 1,
          limit: 1,
          totalPages: 2,
        ),
      );
      await cubit.fetchMyOrders();

      // Second page
      fakeRepository.resultToReturn = Success(
        MyOrdersPage(
          orders: [testOrder2],
          total: 2,
          page: 2,
          limit: 1,
          totalPages: 2,
        ),
      );
      await cubit.loadMore();

      final currentState = cubit.state as MyOrdersLoaded;
      expect(currentState.orders.length, 2);
      expect(currentState.page, 2);
      expect(currentState.hasReachedMax, isTrue);
      expect(currentState.isLoadingMore, isFalse);
    });

    test('loadMore updates loadingMoreError when next page fails', () async {
      fakeRepository.resultToReturn = Success(
        MyOrdersPage(
          orders: [testOrder1],
          total: 2,
          page: 1,
          limit: 1,
          totalPages: 2,
        ),
      );
      await cubit.fetchMyOrders();

      fakeRepository.resultToReturn = const Err(
        Network(serverMessage: 'انقطع الاتصال'),
      );
      await cubit.loadMore();

      final currentState = cubit.state as MyOrdersLoaded;
      expect(currentState.orders.length, 1);
      expect(currentState.isLoadingMore, isFalse);
      expect(currentState.loadingMoreError, isA<Network>());
    });

    test('loadMore stops at last page and does not call repository when hasReachedMax is true', () async {
      fakeRepository.resultToReturn = Success(
        MyOrdersPage(
          orders: [testOrder1],
          total: 1,
          page: 1,
          limit: 1,
          totalPages: 1,
        ),
      );
      await cubit.fetchMyOrders();

      final state = cubit.state as MyOrdersLoaded;
      expect(state.hasReachedMax, isTrue);

      final initialCallCount = fakeRepository.callCount;
      await cubit.loadMore();

      // No new network/repository call was performed
      expect(fakeRepository.callCount, equals(initialCallCount));
      expect(cubit.state, equals(state));
    });

    test('setFilter correctly filters orders in MyOrdersLoaded', () async {
      fakeRepository.resultToReturn = Success(
        MyOrdersPage(
          orders: [testOrder1, testOrder2],
          total: 2,
          page: 1,
          limit: 2,
          totalPages: 1,
        ),
      );
      await cubit.fetchMyOrders();

      final loadedState = cubit.state as MyOrdersLoaded;
      expect(loadedState.filteredOrders.length, 2);
      expect(loadedState.countActive, 1);
      expect(loadedState.countPast, 1);

      cubit.setFilter(OrderFilter.active);
      final activeState = cubit.state as MyOrdersLoaded;
      expect(activeState.filter, OrderFilter.active);
      expect(activeState.filteredOrders.length, 1);
      expect(activeState.filteredOrders.first.orderNumber, 'ONL-001');

      cubit.setFilter(OrderFilter.past);
      final pastState = cubit.state as MyOrdersLoaded;
      expect(pastState.filter, OrderFilter.past);
      expect(pastState.filteredOrders.length, 1);
      expect(pastState.filteredOrders.first.orderNumber, 'ONL-002');
    });
  });
}
