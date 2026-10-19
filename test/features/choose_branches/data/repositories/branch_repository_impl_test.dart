import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart' hide Timeout;
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/features/choose_branches/data/datasources/branch_remote_data_source.dart';
import 'package:index_pharma/features/choose_branches/data/models/branch_model.dart';
import 'package:index_pharma/features/choose_branches/data/repositories/branch_repository_impl.dart';
import 'package:index_pharma/features/choose_branches/domain/entities/branch_entity.dart';

class FakeBranchRemoteDataSource implements BranchRemoteDataSource {
  List<BranchModel>? mockBranches;
  Object? errorToThrow;

  @override
  Future<List<BranchModel>> getBranches() async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return mockBranches ?? [];
  }
}

void main() {
  late FakeBranchRemoteDataSource fakeRemoteDataSource;
  late BranchRepositoryImpl repository;

  final testRequestOptions = RequestOptions(path: '/store/branches');

  setUp(() {
    fakeRemoteDataSource = FakeBranchRemoteDataSource();
    repository = BranchRepositoryImpl(remoteDataSource: fakeRemoteDataSource);
  });

  group('BranchRepositoryImpl Tests', () {
    test('getBranches returns Success with mapped entities on successful response', () async {
      fakeRemoteDataSource.mockBranches = const [
        BranchModel(
          id: 'branch-1',
          name: 'Main Branch',
          address: 'Cairo',
          phone: '01012345678',
        ),
        BranchModel(
          id: 'branch-2',
          name: 'Maadi Branch',
          address: 'Degla Maadi',
          phone: '0225194432',
        ),
      ];

      final result = await repository.getBranches();

      expect(result, isA<Success<List<BranchEntity>>>());
      final data = (result as Success<List<BranchEntity>>).data;
      expect(data.length, equals(2));
      expect(data[0].id, equals('branch-1'));
      expect(data[0].name, equals('Main Branch'));
      expect(data[0].address, equals('Cairo'));
      expect(data[0].phone, equals('01012345678'));
      expect(data[1].id, equals('branch-2'));
      expect(data[1].name, equals('Maadi Branch'));
    });

    test('getBranches returns Success with empty list when no branches exist', () async {
      fakeRemoteDataSource.mockBranches = [];

      final result = await repository.getBranches();

      expect(result, isA<Success<List<BranchEntity>>>());
      final data = (result as Success<List<BranchEntity>>).data;
      expect(data, isEmpty);
    });

    test('getBranches maps DioException 404 to NotFound Failure', () async {
      fakeRemoteDataSource.errorToThrow = DioException(
        requestOptions: testRequestOptions,
        response: Response(
          requestOptions: testRequestOptions,
          statusCode: 404,
          data: {'message': 'الفرع غير موجود'},
        ),
      );

      final result = await repository.getBranches();

      expect(result, isA<Err<List<BranchEntity>>>());
      final failure = (result as Err<List<BranchEntity>>).failure;
      expect(failure, isA<NotFound>());
      expect(failure.serverMessage, equals('الفرع غير موجود'));
    });

    test('getBranches maps DioException 500 to Server Failure', () async {
      fakeRemoteDataSource.errorToThrow = DioException(
        requestOptions: testRequestOptions,
        response: Response(
          requestOptions: testRequestOptions,
          statusCode: 500,
          data: {'message': 'خطأ داخلي في الخادم'},
        ),
      );

      final result = await repository.getBranches();

      expect(result, isA<Err<List<BranchEntity>>>());
      final failure = (result as Err<List<BranchEntity>>).failure;
      expect(failure, isA<Server>());
      expect(failure.serverMessage, equals('خطأ داخلي في الخادم'));
    });

    test('getBranches maps connection error to Network Failure', () async {
      fakeRemoteDataSource.errorToThrow = DioException(
        requestOptions: testRequestOptions,
        type: DioExceptionType.connectionError,
      );

      final result = await repository.getBranches();

      expect(result, isA<Err<List<BranchEntity>>>());
      final failure = (result as Err<List<BranchEntity>>).failure;
      expect(failure, isA<Network>());
    });

    test('getBranches maps connection timeout to Timeout Failure', () async {
      fakeRemoteDataSource.errorToThrow = DioException(
        requestOptions: testRequestOptions,
        type: DioExceptionType.connectionTimeout,
      );

      final result = await repository.getBranches();

      expect(result, isA<Err<List<BranchEntity>>>());
      final failure = (result as Err<List<BranchEntity>>).failure;
      expect(failure, isA<Timeout>());
    });

    test('getBranches maps unexpected error to Unexpected Failure', () async {
      fakeRemoteDataSource.errorToThrow = const FormatException('Corrupted response');

      final result = await repository.getBranches();

      expect(result, isA<Err<List<BranchEntity>>>());
      final failure = (result as Err<List<BranchEntity>>).failure;
      expect(failure, isA<Unexpected>());
    });
  });
}
