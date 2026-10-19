import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/features/categories/data/models/category_model.dart';
import 'package:index_pharma/features/products/data/datasources/products_remote_data_source.dart';
import 'package:index_pharma/features/products/data/models/product_model.dart';
import 'package:index_pharma/features/products/data/models/products_page_model.dart';
import 'package:index_pharma/features/products/data/repositories/products_repository_impl.dart';
import 'package:index_pharma/features/products/domain/entities/products_page.dart';

class FakeProductsRemoteDataSource implements ProductsRemoteDataSource {
  ProductsPageModel? mockPage;
  Object? errorToThrow;

  @override
  Future<ProductsPageModel> getProducts({
    required String branchId,
    int page = 1,
    int limit = 20,
    String? keyword,
    String? category,
  }) async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return mockPage ??
        const ProductsPageModel(
          total: 0,
          totalPages: 0,
          page: 1,
          limit: 20,
          products: [],
        );
  }
}

void main() {
  late FakeProductsRemoteDataSource fakeDataSource;
  late ProductsRepositoryImpl repository;

  final testRequestOptions = RequestOptions(path: '/store/products');

  setUp(() {
    fakeDataSource = FakeProductsRemoteDataSource();
    repository = ProductsRepositoryImpl(remoteDataSource: fakeDataSource);
  });

  group('ProductsRepositoryImpl Tests', () {
    test('getProducts returns Success with mapped ProductsPage entity',
        () async {
      fakeDataSource.mockPage = const ProductsPageModel(
        total: 1,
        totalPages: 1,
        page: 1,
        limit: 20,
        products: [
          ProductModel(
            id: 'p01',
            name: 'Hydrating Cream 50ml',
            scientificName: 'Hyaluronic Acid',
            barcode: '6221000000028',
            sellingPrice: 130.0,
            stockQuantity: 30,
            looseQuantity: 0,
            requiresPrescription: false,
            category: CategoryModel(id: 'c01', name: 'Skincare'),
            branchId: 'b01',
          ),
        ],
      );

      final result = await repository.getProducts(branchId: 'b01');

      expect(result, isA<Success<ProductsPage>>());
      final page = (result as Success<ProductsPage>).data;
      expect(page.total, equals(1));
      expect(page.totalPages, equals(1));
      expect(page.page, equals(1));
      expect(page.products.length, equals(1));
      expect(page.products.first.name, equals('Hydrating Cream 50ml'));
      expect(page.products.first.sellingPrice, equals(130.0));
      expect(page.products.first.category?.name, equals('Skincare'));
    });

    test('getProducts returns Success with empty page', () async {
      fakeDataSource.mockPage = const ProductsPageModel(
        total: 0,
        totalPages: 0,
        page: 1,
        limit: 20,
        products: [],
      );

      final result = await repository.getProducts(branchId: 'b01');

      expect(result, isA<Success<ProductsPage>>());
      final page = (result as Success<ProductsPage>).data;
      expect(page.products, isEmpty);
      expect(page.total, equals(0));
    });

    test('getProducts maps DioException 400 to Validation Failure', () async {
      fakeDataSource.errorToThrow = DioException(
        requestOptions: testRequestOptions,
        response: Response(
          requestOptions: testRequestOptions,
          statusCode: 400,
          data: {'message': 'يرجى اختيار الفرع لعرض مخزون المتجر'},
        ),
      );

      final result = await repository.getProducts(branchId: '');

      expect(result, isA<Err<ProductsPage>>());
      final failure = (result as Err<ProductsPage>).failure;
      expect(failure, isA<Validation>());
      expect(failure.serverMessage, equals('يرجى اختيار الفرع لعرض مخزون المتجر'));
    });

    test('getProducts maps DioException 500 to Server Failure', () async {
      fakeDataSource.errorToThrow = DioException(
        requestOptions: testRequestOptions,
        response: Response(
          requestOptions: testRequestOptions,
          statusCode: 500,
          data: {'message': 'خطأ في السيرفر'},
        ),
      );

      final result = await repository.getProducts(branchId: 'b01');

      expect(result, isA<Err<ProductsPage>>());
      final failure = (result as Err<ProductsPage>).failure;
      expect(failure, isA<Server>());
      expect(failure.serverMessage, equals('خطأ في السيرفر'));
    });

    test('getProducts maps connection error to Network Failure', () async {
      fakeDataSource.errorToThrow = DioException(
        requestOptions: testRequestOptions,
        type: DioExceptionType.connectionError,
      );

      final result = await repository.getProducts(branchId: 'b01');

      expect(result, isA<Err<ProductsPage>>());
      final failure = (result as Err<ProductsPage>).failure;
      expect(failure, isA<Network>());
    });

    test('getProducts maps unexpected exception to Unexpected Failure',
        () async {
      fakeDataSource.errorToThrow =
          const FormatException('Corrupted response payload');

      final result = await repository.getProducts(branchId: 'b01');

      expect(result, isA<Err<ProductsPage>>());
      final failure = (result as Err<ProductsPage>).failure;
      expect(failure, isA<Unexpected>());
    });
  });
}
