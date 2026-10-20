import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/features/checkout/data/models/order_model.dart';
import 'package:index_pharma/features/checkout/data/models/order_request_model.dart';

void main() {
  group('OrderRequestModel Serialization', () {
    test('serializes strictly according to POST /store/orders specification', () {
      const request = OrderRequestModel(
        branchId: 'b18f3a22-3118-4089-9e8c-529a6e118901',
        orderItems: [
          OrderItemRequestModel(
            productId: 'p02f8a22-2228-4089-9e8c-669a6e118988',
            quantity: 2,
          ),
          OrderItemRequestModel(
            productId: 'p01f8a22-1118-4089-9e8c-669a6e118999',
            quantity: 1,
          ),
        ],
        deliveryAddress: 'Nasr City, Cairo, Building 4',
        customerPhone: '01012345678',
        notes: 'يرجى الاتصال قبل الوصول',
      );

      final json = request.toJson();

      expect(json['branchId'], 'b18f3a22-3118-4089-9e8c-529a6e118901');
      expect(json['deliveryAddress'], 'Nasr City, Cairo, Building 4');
      expect(json['customerPhone'], '01012345678');
      expect(json['notes'], 'يرجى الاتصال قبل الوصول');

      final items = json['orderItems'] as List<dynamic>;
      expect(items.length, 2);
      expect(items[0], {
        'productId': 'p02f8a22-2228-4089-9e8c-669a6e118988',
        'quantity': 2,
      });

      // Crucial constraint: prices and unit flags must NOT be in the request payload
      expect(json.containsKey('subtotal'), isFalse);
      expect(json.containsKey('totalAmount'), isFalse);
      expect(items[0].containsKey('isUnit'), isFalse);
      expect(items[0].containsKey('isSecondaryUnit'), isFalse);
      expect(items[0].containsKey('priceAtPurchase'), isFalse);
    });

    test('omits notes when null or empty', () {
      const request = OrderRequestModel(
        branchId: 'b1',
        orderItems: [
          OrderItemRequestModel(productId: 'p1', quantity: 1),
        ],
        deliveryAddress: 'Addr',
        customerPhone: '01012345678',
        notes: '   ',
      );

      final json = request.toJson();
      expect(json.containsKey('notes'), isFalse);
    });
  });

  group('OrderModel Deserialization', () {
    test('deserializes 201 real response matching §8.1 sample', () {
      final sampleJson = {
        'success': true,
        'data': {
          'id': 'ord-887123aa-9912-4f81-81b3-4412398fa101',
          'orderNumber': 'ONL-20261018-001',
          'customerId': 'e98df12a-3312-40bb-97dc-712891bcfa10',
          'branchId': 'b18f3a22-3118-4089-9e8c-529a6e118901',
          'subtotal': 170,
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
          'items': [
            {
              'id': 'item-01',
              'orderId': 'ord-887123aa-9912-4f81-81b3-4412398fa101',
              'productId': 'p02f8a22-2228-4089-9e8c-669a6e118988',
              'productName': 'Vitamin C 1000mg',
              'quantity': 2,
              'priceAtPurchase': 85,
              'costAtSale': 60,
              'isUnit': false,
              'isSecondaryUnit': false,
            }
          ]
        }
      };

      final orderModel = OrderModel.fromJson(sampleJson);
      final entity = orderModel.toEntity();

      expect(entity.id, 'ord-887123aa-9912-4f81-81b3-4412398fa101');
      expect(entity.orderNumber, 'ONL-20261018-001');
      expect(entity.branchId, 'b18f3a22-3118-4089-9e8c-529a6e118901');
      expect(entity.subtotal, 170.0);
      expect(entity.totalAmount, 170.0);
      expect(entity.paymentMethod, 'cash');
      expect(entity.status, 'pending');
      expect(entity.deliveryAddress, 'Nasr City, Cairo, Building 4');
      expect(entity.customerPhone, '01012345678');
      expect(entity.items.length, 1);

      final item = entity.items.first;
      expect(item.id, 'item-01');
      expect(item.productId, 'p02f8a22-2228-4089-9e8c-669a6e118988');
      expect(item.productName, 'Vitamin C 1000mg');
      expect(item.quantity, 2);
      expect(item.priceAtPurchase, 85.0);
      expect(item.lineTotal, 170.0);
    });
  });
}
