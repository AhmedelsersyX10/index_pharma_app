import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/features/orders/data/datasources/orders_remote_data_source.dart';
import 'package:index_pharma/features/orders/data/models/customer_order_item_model.dart';
import 'package:index_pharma/features/orders/data/models/customer_order_model.dart';
import 'package:index_pharma/features/orders/data/models/my_orders_response_model.dart';
import 'package:index_pharma/features/orders/data/repositories/orders_repository_impl.dart';

class FakeOrdersRemoteDataSource implements OrdersRemoteDataSource {
  MyOrdersResponseModel? modelToReturn;
  Object? errorToThrow;
  int? lastPage;
  int? lastLimit;

  @override
  Future<MyOrdersResponseModel> getMyOrders({
    int page = 1,
    int limit = 20,
  }) async {
    lastPage = page;
    lastLimit = limit;
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    if (modelToReturn != null) {
      return modelToReturn!;
    }
    throw const FormatException('No response configured');
  }
}

void main() {
  group('OrdersRepositoryImpl Tests', () {
    late FakeOrdersRemoteDataSource fakeDataSource;
    late OrdersRepositoryImpl repository;

    setUp(() {
      fakeDataSource = FakeOrdersRemoteDataSource();
      repository = OrdersRepositoryImpl(remoteDataSource: fakeDataSource);
    });

    final testResponseModel = MyOrdersResponseModel(
      success: true,
      count: 1,
      total: 10,
      page: 1,
      limit: 20,
      totalPages: 1,
      data: [
        CustomerOrderModel(
          id: 'ord-1',
          orderNumber: 'ONL-101',
          subtotal: 100,
          totalAmount: 100,
          orderType: 'ONLINE',
          status: 'pending',
          paymentMethod: 'cash',
          deliveryAddress: 'Cairo',
          customerPhone: '01012345678',
          createdAt: DateTime(2026, 10, 18),
          items: const [
            CustomerOrderItemModel(
              id: 'it-1',
              productId: 'p-1',
              productName: 'Panadol',
              quantity: 2,
              priceAtPurchase: 50,
            ),
          ],
        ),
      ],
    );

    test('getMyOrders returns Success<MyOrdersPage> on successful data source call',
        () async {
      fakeDataSource.modelToReturn = testResponseModel;

      final result = await repository.getMyOrders(page: 1, limit: 20);

      expect(result, isA<Success>());
      final page = (result as Success).data;
      expect(page.total, 10);
      expect(page.orders.length, 1);
      expect(page.orders.first.orderNumber, 'ONL-101');
      expect(fakeDataSource.lastPage, 1);
      expect(fakeDataSource.lastLimit, 20);
    });

    test('getMyOrders maps 401 DioException to Err<Unauthorized>', () async {
      fakeDataSource.errorToThrow = DioException(
        requestOptions: RequestOptions(path: '/store/orders/my'),
        response: Response(
          requestOptions: RequestOptions(path: '/store/orders/my'),
          statusCode: 401,
          data: {'message': 'يرجى تسجيل الدخول'},
        ),
        type: DioExceptionType.badResponse,
      );

      final result = await repository.getMyOrders();

      expect(result, isA<Err>());
      final failure = (result as Err).failure;
      expect(failure, isA<Unauthorized>());
      expect(failure.serverMessage, 'يرجى تسجيل الدخول');
    });

    test('getMyOrders maps network DioException to Err<Network>', () async {
      fakeDataSource.errorToThrow = DioException(
        requestOptions: RequestOptions(path: '/store/orders/my'),
        type: DioExceptionType.connectionError,
      );

      final result = await repository.getMyOrders();

      expect(result, isA<Err>());
      expect((result as Err).failure, isA<Network>());
    });

    test('getMyOrders maps unexpected exceptions to Err<Unexpected>', () async {
      fakeDataSource.errorToThrow = const FormatException('Corrupted response');

      final result = await repository.getMyOrders();

      expect(result, isA<Err>());
      expect((result as Err).failure, isA<Unexpected>());
    });
  });
}
