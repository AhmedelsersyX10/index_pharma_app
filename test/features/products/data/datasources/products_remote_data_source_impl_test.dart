import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/features/products/data/datasources/products_remote_data_source_impl.dart';

void main() {
  late Dio dio;
  late ProductsRemoteDataSourceImpl dataSource;

  setUp(() {
    dio = Dio();
    dataSource = ProductsRemoteDataSourceImpl(dio: dio);
  });

  group('ProductsRemoteDataSourceImpl Tests', () {
    test('parses real JSON sample successfully with pagination fields',
        () async {
      final sampleJson = {
        'success': true,
        'count': 1,
        'total': 3,
        'page': 1,
        'limit': 5,
        'totalPages': 1,
        'branchId': 'b18f3a22-3118-4089-9e8c-529a6e118901',
        'data': [
          {
            'id': 'p01f8a22-1118-4089-9e8c-669a6e118999',
            'name': 'Hydrating Cream 50ml',
            'scientificName': 'Hyaluronic Acid',
            'barcode': '6221000000028',
            'description':
                'Daily moisturizing cream for dry and sensitive skin',
            'image': '/uploads/products/cream.jpg',
            'sellingPrice': 130,
            'stockQuantity': 30,
            'looseQuantity': 0,
            'expiryDate': '2028-06-30T00:00:00.000Z',
            'requiresPrescription': false,
            'unit': 'قطعة',
            'category': {
              'id': 'c10f8a91-4418-4089-9e8c-779a6e118902',
              'name': 'Skincare',
            },
            'branchId': 'b18f3a22-3118-4089-9e8c-529a6e118901',
          }
        ],
      };

      RequestOptions? capturedOptions;

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedOptions = options;
            handler.resolve(
              Response(
                requestOptions: options,
                data: sampleJson,
                statusCode: 200,
              ),
            );
          },
        ),
      );

      final result = await dataSource.getProducts(
        branchId: 'b18f3a22-3118-4089-9e8c-529a6e118901',
        page: 1,
        limit: 5,
        keyword: 'Hydrating',
        category: 'c10f8a91',
      );

      expect(capturedOptions?.queryParameters['branchId'],
          equals('b18f3a22-3118-4089-9e8c-529a6e118901'));
      expect(capturedOptions?.queryParameters['page'], equals(1));
      expect(capturedOptions?.queryParameters['limit'], equals(5));
      expect(capturedOptions?.queryParameters['keyword'], equals('Hydrating'));
      expect(capturedOptions?.queryParameters['category'], equals('c10f8a91'));

      expect(result.total, equals(3));
      expect(result.totalPages, equals(1));
      expect(result.page, equals(1));
      expect(result.limit, equals(5));
      expect(result.isLastPage, isTrue);

      expect(result.products.length, equals(1));
      final product = result.products.first;
      expect(product.id, equals('p01f8a22-1118-4089-9e8c-669a6e118999'));
      expect(product.name, equals('Hydrating Cream 50ml'));
      expect(product.scientificName, equals('Hyaluronic Acid'));
      expect(product.barcode, equals('6221000000028'));
      expect(product.sellingPrice, equals(130.0));
      expect(product.stockQuantity, equals(30));
      expect(product.looseQuantity, equals(0));
      expect(product.requiresPrescription, isFalse);
      expect(product.category?.name, equals('Skincare'));
    });

    test('parses empty data list successfully', () async {
      final emptyJson = {
        'success': true,
        'count': 0,
        'total': 0,
        'page': 1,
        'limit': 20,
        'totalPages': 0,
        'branchId': 'branch-1',
        'data': [],
      };

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                data: emptyJson,
                statusCode: 200,
              ),
            );
          },
        ),
      );

      final result = await dataSource.getProducts(branchId: 'branch-1');
      expect(result.products, isEmpty);
      expect(result.total, equals(0));
      expect(result.isLastPage, isTrue);
    });

    test('throws FormatException when response format is not a map', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                data: 'unexpected string',
                statusCode: 200,
              ),
            );
          },
        ),
      );

      expect(
        () => dataSource.getProducts(branchId: 'branch-1'),
        throwsA(isA<FormatException>()),
      );
    });

    test('getProductById parses real JSON sample successfully', () async {
      final sampleDetailJson = {
        'success': true,
        'data': {
          'id': 'p01f8a22-1118-4089-9e8c-669a6e118999',
          'name': 'Hydrating Cream 50ml',
          'scientificName': 'Hyaluronic Acid',
          'barcode': '6221000000028',
          'description': 'Daily moisturizing cream for dry and sensitive skin',
          'image': null,
          'sellingPrice': 130,
          'stockQuantity': 30,
          'expiryDate': '2028-06-30T00:00:00.000Z',
          'requiresPrescription': false,
          'unit': 'قطعة',
          'category': {
            'id': 'c10f8a91-4418-4089-9e8c-779a6e118902',
            'name': 'Skincare',
          },
          'looseQuantity': 0,
          'branchId': 'b18f3a22-3118-4089-9e8c-529a6e118901',
        },
      };

      RequestOptions? capturedOptions;

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedOptions = options;
            handler.resolve(
              Response(
                requestOptions: options,
                data: sampleDetailJson,
                statusCode: 200,
              ),
            );
          },
        ),
      );

      final result = await dataSource.getProductById(
        productId: 'p01f8a22-1118-4089-9e8c-669a6e118999',
        branchId: 'b18f3a22-3118-4089-9e8c-529a6e118901',
      );

      expect(capturedOptions?.path, equals('/store/products/p01f8a22-1118-4089-9e8c-669a6e118999'));
      expect(capturedOptions?.queryParameters['branchId'], equals('b18f3a22-3118-4089-9e8c-529a6e118901'));
      expect(result.id, equals('p01f8a22-1118-4089-9e8c-669a6e118999'));
      expect(result.name, equals('Hydrating Cream 50ml'));
      expect(result.sellingPrice, equals(130.0));
      expect(result.stockQuantity, equals(30));
      expect(result.requiresPrescription, isFalse);
      expect(result.category?.name, equals('Skincare'));
    });

    test('getProductById throws ArgumentError if branchId is empty', () async {
      expect(
        () => dataSource.getProductById(productId: 'p1', branchId: '   '),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('getProductById throws FormatException when response format is invalid', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                data: {'success': false},
                statusCode: 200,
              ),
            );
          },
        ),
      );

      expect(
        () => dataSource.getProductById(productId: 'p1', branchId: 'b1'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
