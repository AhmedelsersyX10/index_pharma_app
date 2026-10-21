import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/features/checkout/data/datasources/checkout_remote_data_source.dart';
import 'package:index_pharma/features/checkout/data/models/order_model.dart';
import 'package:index_pharma/features/checkout/data/models/order_request_model.dart';
import 'package:index_pharma/features/checkout/data/repositories/checkout_repository_impl.dart';

class FakeCheckoutRemoteDataSource implements CheckoutRemoteDataSource {
  OrderModel? modelToReturn;
  Object? errorToThrow;
  OrderRequestModel? lastRequest;

  @override
  Future<OrderModel> createOrder(OrderRequestModel request) async {
    lastRequest = request;
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    if (modelToReturn != null) {
      return modelToReturn!;
    }
    throw const FormatException('No model or error configured in fake');
  }
}

void main() {
  late FakeCheckoutRemoteDataSource fakeDataSource;
  late CheckoutRepositoryImpl repository;

  setUp(() {
    fakeDataSource = FakeCheckoutRemoteDataSource();
    repository = CheckoutRepositoryImpl(remoteDataSource: fakeDataSource);
  });

  const testRequest = OrderRequestModel(
    branchId: 'b1',
    orderItems: [
      OrderItemRequestModel(productId: 'p1', quantity: 2),
    ],
    deliveryAddress: 'Nasr City, Cairo',
    customerPhone: '01012345678',
  );

  final testOrderModel = OrderModel(
    id: 'ord-1',
    orderNumber: 'ONL-001',
    customerId: 'c-1',
    branchId: 'b1',
    subtotal: 100,
    totalAmount: 100,
    paidAmount: 0,
    dueAmount: 100,
    changeAmount: 0,
    orderType: 'ONLINE',
    status: 'pending',
    paymentMethod: 'cash',
    deliveryAddress: 'Nasr City, Cairo',
    customerPhone: '01012345678',
    createdAt: DateTime.now(),
    items: const [],
  );

  group('CheckoutRepositoryImpl.createOrder', () {
    test('returns Success(Order) on HTTP 201 response', () async {
      fakeDataSource.modelToReturn = testOrderModel;

      final result = await repository.createOrder(testRequest);

      expect(result, isA<Success>());
      final order = (result as Success).data;
      expect(order.id, 'ord-1');
      expect(order.orderNumber, 'ONL-001');
      expect(fakeDataSource.lastRequest, testRequest);
    });

    test('maps HTTP 409 response to Err(Conflict)', () async {
      fakeDataSource.errorToThrow = DioException(
        requestOptions: RequestOptions(path: '/store/orders'),
        response: Response(
          requestOptions: RequestOptions(path: '/store/orders'),
          statusCode: 409,
          data: {
            'success': false,
            'message': 'الكمية المتاحة من Hydrating Cream 50ml هي 29 فقط',
          },
        ),
      );

      final result = await repository.createOrder(testRequest);

      expect(result, isA<Err>());
      final failure = (result as Err).failure;
      expect(failure, isA<Conflict>());
      expect(failure.serverMessage,
          'الكمية المتاحة من Hydrating Cream 50ml هي 29 فقط');
    });

    test('maps HTTP 409 response with missing message to Err(Conflict)', () async {
      fakeDataSource.errorToThrow = DioException(
        requestOptions: RequestOptions(path: '/store/orders'),
        response: Response(
          requestOptions: RequestOptions(path: '/store/orders'),
          statusCode: 409,
          data: {'success': false},
        ),
      );

      final result = await repository.createOrder(testRequest);

      expect(result, isA<Err>());
      final failure = (result as Err).failure;
      expect(failure, isA<Conflict>());
    });

    test('maps HTTP 404 response to Err(NotFound)', () async {
      fakeDataSource.errorToThrow = DioException(
        requestOptions: RequestOptions(path: '/store/orders'),
        response: Response(
          requestOptions: RequestOptions(path: '/store/orders'),
          statusCode: 404,
          data: {
            'success': false,
            'message': 'أحد المنتجات غير متاح حالياً',
          },
        ),
      );

      final result = await repository.createOrder(testRequest);

      expect(result, isA<Err>());
      final failure = (result as Err).failure;
      expect(failure, isA<NotFound>());
      expect(failure.serverMessage, 'أحد المنتجات غير متاح حالياً');
    });

    test('maps HTTP 400 response to Err(Validation)', () async {
      fakeDataSource.errorToThrow = DioException(
        requestOptions: RequestOptions(path: '/store/orders'),
        response: Response(
          requestOptions: RequestOptions(path: '/store/orders'),
          statusCode: 400,
          data: {
            'success': false,
            'message': 'السلة فارغة',
          },
        ),
      );

      final result = await repository.createOrder(testRequest);

      expect(result, isA<Err>());
      final failure = (result as Err).failure;
      expect(failure, isA<Validation>());
      expect(failure.serverMessage, 'السلة فارغة');
    });

    test('maps HTTP 401 response to Err(Unauthorized)', () async {
      fakeDataSource.errorToThrow = DioException(
        requestOptions: RequestOptions(path: '/store/orders'),
        response: Response(
          requestOptions: RequestOptions(path: '/store/orders'),
          statusCode: 401,
          data: {
            'success': false,
            'message': 'غير مصرح',
          },
        ),
      );

      final result = await repository.createOrder(testRequest);

      expect(result, isA<Err>());
      final failure = (result as Err).failure;
      expect(failure, isA<Unauthorized>());
      expect(failure.serverMessage, 'غير مصرح');
    });

    test('maps HTTP 500 response to Err(Server)', () async {
      fakeDataSource.errorToThrow = DioException(
        requestOptions: RequestOptions(path: '/store/orders'),
        response: Response(
          requestOptions: RequestOptions(path: '/store/orders'),
          statusCode: 500,
          data: {'message': 'خطأ في الخادم'},
        ),
      );

      final result = await repository.createOrder(testRequest);

      expect(result, isA<Err>());
      final failure = (result as Err).failure;
      expect(failure, isA<Server>());
    });
  });
}
