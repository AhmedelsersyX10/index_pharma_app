import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart' hide Timeout;
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/features/categories/data/datasources/categories_remote_data_source.dart';
import 'package:index_pharma/features/categories/data/models/category_model.dart';
import 'package:index_pharma/features/categories/data/repositories/categories_repository_impl.dart';
import 'package:index_pharma/features/categories/domain/entities/category.dart';

class FakeCategoriesRemoteDataSource implements CategoriesRemoteDataSource {
  List<CategoryModel>? mockCategories;
  Object? errorToThrow;

  @override
  Future<List<CategoryModel>> getCategories() async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return mockCategories ?? <CategoryModel>[];
  }
}

void main() {
  late FakeCategoriesRemoteDataSource fakeDataSource;
  late CategoriesRepositoryImpl repository;

  final testRequestOptions = RequestOptions(path: '/store/categories');

  setUp(() {
    fakeDataSource = FakeCategoriesRemoteDataSource();
    repository = CategoriesRepositoryImpl(remoteDataSource: fakeDataSource);
  });

  group('CategoriesRepositoryImpl Tests', () {
    test('getCategories returns Success with mapped entities on success', () async {
      fakeDataSource.mockCategories = const [
        CategoryModel(id: 'cmv9bxrwr0003wqgoxhdft6rb', name: 'Skincare'),
        CategoryModel(id: 'cmv9bxrw70002wqgo7j1crx4h', name: 'Vitamins'),
      ];

      final result = await repository.getCategories();

      expect(result, isA<Success<List<Category>>>());
      final categories = (result as Success<List<Category>>).data;
      expect(categories.length, equals(2));
      expect(categories[0].id, equals('cmv9bxrwr0003wqgoxhdft6rb'));
      expect(categories[0].name, equals('Skincare'));
      expect(categories[1].id, equals('cmv9bxrw70002wqgo7j1crx4h'));
      expect(categories[1].name, equals('Vitamins'));
    });

    test('getCategories returns Success with empty list when data source returns empty list', () async {
      fakeDataSource.mockCategories = const [];

      final result = await repository.getCategories();

      expect(result, isA<Success<List<Category>>>());
      final categories = (result as Success<List<Category>>).data;
      expect(categories, isEmpty);
    });

    test('getCategories maps DioException 500 to Server Failure', () async {
      fakeDataSource.errorToThrow = DioException(
        requestOptions: testRequestOptions,
        response: Response(
          requestOptions: testRequestOptions,
          statusCode: 500,
          data: {'message': 'خطأ في السيرفر'},
        ),
      );

      final result = await repository.getCategories();

      expect(result, isA<Err<List<Category>>>());
      final failure = (result as Err<List<Category>>).failure;
      expect(failure, isA<Server>());
      expect(failure.serverMessage, equals('خطأ في السيرفر'));
    });

    test('getCategories maps connection error to Network Failure', () async {
      fakeDataSource.errorToThrow = DioException(
        requestOptions: testRequestOptions,
        type: DioExceptionType.connectionError,
      );

      final result = await repository.getCategories();

      expect(result, isA<Err<List<Category>>>());
      final failure = (result as Err<List<Category>>).failure;
      expect(failure, isA<Network>());
    });

    test('getCategories maps unexpected exception to Unexpected Failure', () async {
      fakeDataSource.errorToThrow = const FormatException('Corrupted response');

      final result = await repository.getCategories();

      expect(result, isA<Err<List<Category>>>());
      final failure = (result as Err<List<Category>>).failure;
      expect(failure, isA<Unexpected>());
    });
  });
}
