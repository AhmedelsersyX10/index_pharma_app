import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/features/categories/data/datasources/categories_remote_data_source_impl.dart';

void main() {
  late Dio dio;
  late CategoriesRemoteDataSourceImpl dataSource;

  setUp(() {
    dio = Dio();
    dataSource = CategoriesRemoteDataSourceImpl(dio: dio);
  });

  group('CategoriesRemoteDataSourceImpl', () {
    test('parses real JSON sample successfully', () async {
      final sampleJson = {
        'success': true,
        'count': 2,
        'data': [
          {
            'id': 'cmv9bxrwr0003wqgoxhdft6rb',
            'name': 'Skincare',
          },
          {
            'id': 'cmv9bxrw70002wqgo7j1crx4h',
            'name': 'Vitamins',
          }
        ]
      };

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
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

      final result = await dataSource.getCategories();

      expect(result.length, equals(2));
      expect(result[0].id, equals('cmv9bxrwr0003wqgoxhdft6rb'));
      expect(result[0].name, equals('Skincare'));
      expect(result[1].id, equals('cmv9bxrw70002wqgo7j1crx4h'));
      expect(result[1].name, equals('Vitamins'));
    });

    test('parses empty data list successfully', () async {
      final emptyJson = {
        'success': true,
        'count': 0,
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

      final result = await dataSource.getCategories();
      expect(result, isEmpty);
    });

    test('throws FormatException when response format is invalid', () async {
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

      expect(() => dataSource.getCategories(), throwsA(isA<FormatException>()));
    });
  });
}
