import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/features/orders/data/models/customer_order_item_model.dart';
import 'package:index_pharma/features/orders/data/models/customer_order_model.dart';
import 'package:index_pharma/features/orders/data/models/my_orders_response_model.dart';
import 'package:index_pharma/features/orders/domain/entities/order_status.dart';

void main() {
  group('Customer Order Models Tests', () {
    const realSampleJson = {
      'success': true,
      'count': 1,
      'total': 1,
      'page': 1,
      'limit': 3,
      'totalPages': 1,
      'data': [
        {
          'id': 'ord-887123aa-9912-4f81-81b3-4412398fa101',
          'orderNumber': 'ONL-20261018-001',
          'subtotal': 170,
          'discountType': 'fixed',
          'discountValue': 0,
          'totalAmount': 170,
          'paidAmount': 0,
          'dueAmount': 170,
          'changeAmount': 0,
          'orderType': 'ONLINE',
          'status': 'pending',
          'paymentMethod': 'cash',
          'deliveryAddress': 'Nasr City, Cairo, Building 4',
          'customerPhone': '01012345678',
          'notes': 'يرجى الاتصال قبل الوصول',
          'createdAt': '2026-10-18T12:30:00.000Z',
          'updatedAt': '2026-10-18T12:30:00.000Z',
          'items': [
            {
              'id': 'item-01',
              'productId': 'p02f8a22-2228-4089-9e8c-669a6e118988',
              'productName': 'Vitamin C 1000mg',
              'quantity': 2,
              'priceAtPurchase': 85,
              'isUnit': false,
            },
          ],
        },
      ],
    };

    test('MyOrdersResponseModel parses real API response sample correctly', () {
      final responseModel = MyOrdersResponseModel.fromJson(realSampleJson);

      expect(responseModel.success, isTrue);
      expect(responseModel.count, 1);
      expect(responseModel.total, 1);
      expect(responseModel.page, 1);
      expect(responseModel.limit, 3);
      expect(responseModel.totalPages, 1);
      expect(responseModel.data.length, 1);

      final orderModel = responseModel.data.first;
      expect(orderModel.id, 'ord-887123aa-9912-4f81-81b3-4412398fa101');
      expect(orderModel.orderNumber, 'ONL-20261018-001');
      expect(orderModel.subtotal, 170.0);
      expect(orderModel.discountType, 'fixed');
      expect(orderModel.discountValue, 0.0);
      expect(orderModel.totalAmount, 170.0);
      expect(orderModel.paidAmount, 0.0);
      expect(orderModel.dueAmount, 170.0);
      expect(orderModel.changeAmount, 0.0);
      expect(orderModel.orderType, 'ONLINE');
      expect(orderModel.status, 'pending');
      expect(orderModel.paymentMethod, 'cash');
      expect(orderModel.deliveryAddress, 'Nasr City, Cairo, Building 4');
      expect(orderModel.customerPhone, '01012345678');
      expect(orderModel.notes, 'يرجى الاتصال قبل الوصول');
      expect(orderModel.items.length, 1);

      final itemModel = orderModel.items.first;
      expect(itemModel.id, 'item-01');
      expect(itemModel.productId, 'p02f8a22-2228-4089-9e8c-669a6e118988');
      expect(itemModel.productName, 'Vitamin C 1000mg');
      expect(itemModel.quantity, 2);
      expect(itemModel.priceAtPurchase, 85.0);
      expect(itemModel.isUnit, isFalse);
    });

    test('toEntity converts models to domain entities with computed values', () {
      final responseModel = MyOrdersResponseModel.fromJson(realSampleJson);
      final entity = responseModel.toEntity();

      expect(entity.total, 1);
      expect(entity.totalPages, 1);
      expect(entity.hasMore, isFalse);
      expect(entity.orders.length, 1);

      final orderEntity = entity.orders.first;
      expect(orderEntity.orderNumber, 'ONL-20261018-001');
      expect(orderEntity.statusEnum, OrderStatus.pending);
      expect(orderEntity.totalItemCount, 2);

      final itemEntity = orderEntity.items.first;
      expect(itemEntity.totalPrice, 170.0);
    });

    test('CustomerOrderModel handles null/missing optional fields safely', () {
      final minimalJson = {'id': 'ord-min', 'orderNumber': 'ONL-MIN', 'totalAmount': 50};

      final order = CustomerOrderModel.fromJson(minimalJson);
      expect(order.id, 'ord-min');
      expect(order.orderNumber, 'ONL-MIN');
      expect(order.subtotal, 0.0);
      expect(order.totalAmount, 50.0);
      expect(order.status, 'pending');
      expect(order.paymentMethod, 'cash');
      expect(order.items, isEmpty);
      expect(order.notes, isNull);
    });

    test('CustomerOrderItemModel handles fallback values correctly', () {
      final minimalItemJson = <String, dynamic>{};
      final item = CustomerOrderItemModel.fromJson(minimalItemJson);

      expect(item.id, '');
      expect(item.productId, '');
      expect(item.productName, '');
      expect(item.quantity, 1);
      expect(item.priceAtPurchase, 0.0);
      expect(item.isUnit, isFalse);
    });

    test('CustomerOrderModel safely maps unknown status string to OrderStatus.unknown', () {
      final orderWithUnknownStatus = {
        'id': 'ord-unknown',
        'orderNumber': 'ONL-UNK',
        'totalAmount': 100,
        'status': 'some_future_status_shipped',
      };

      final order = CustomerOrderModel.fromJson(orderWithUnknownStatus);
      expect(order.status, 'some_future_status_shipped');
      final entity = order.toEntity();
      expect(entity.statusEnum, OrderStatus.unknown);
      expect(entity.statusEnum.isActive, isFalse);
      expect(entity.statusEnum.isPast, isFalse);
    });
  });
}
