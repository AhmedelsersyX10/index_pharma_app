import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart' hide Timeout;
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/features/settings/data/datasources/settings_remote_data_source.dart';
import 'package:index_pharma/features/settings/data/models/public_settings_model.dart';
import 'package:index_pharma/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:index_pharma/features/settings/domain/entities/public_settings.dart';

class FakeSettingsRemoteDataSource implements SettingsRemoteDataSource {
  PublicSettingsModel? mockSettings;
  Object? errorToThrow;

  @override
  Future<PublicSettingsModel> getPublicSettings() async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return mockSettings ?? const PublicSettingsModel();
  }
}

void main() {
  late FakeSettingsRemoteDataSource fakeDataSource;
  late SettingsRepositoryImpl repository;

  final testRequestOptions = RequestOptions(path: '/settings/public');

  setUp(() {
    fakeDataSource = FakeSettingsRemoteDataSource();
    repository = SettingsRepositoryImpl(remoteDataSource: fakeDataSource);
  });

  group('SettingsRepositoryImpl Tests', () {
    test('getPublicSettings returns Success with mapped entity on success', () async {
      fakeDataSource.mockSettings = const PublicSettingsModel(
        pharmacyName: 'Index Pharmacy',
        whatsappNumber: '01012345678',
      );

      final result = await repository.getPublicSettings();

      expect(result, isA<Success<PublicSettings>>());
      final data = (result as Success<PublicSettings>).data;
      expect(data.pharmacyName, equals('Index Pharmacy'));
      expect(data.whatsappNumber, equals('01012345678'));
    });

    test('getPublicSettings maps DioException 500 to Server Failure', () async {
      fakeDataSource.errorToThrow = DioException(
        requestOptions: testRequestOptions,
        response: Response(
          requestOptions: testRequestOptions,
          statusCode: 500,
          data: {'message': 'خطأ في السيرفر'},
        ),
      );

      final result = await repository.getPublicSettings();

      expect(result, isA<Err<PublicSettings>>());
      final failure = (result as Err<PublicSettings>).failure;
      expect(failure, isA<Server>());
      expect(failure.serverMessage, equals('خطأ في السيرفر'));
    });

    test('getPublicSettings maps connection error to Network Failure', () async {
      fakeDataSource.errorToThrow = DioException(
        requestOptions: testRequestOptions,
        type: DioExceptionType.connectionError,
      );

      final result = await repository.getPublicSettings();

      expect(result, isA<Err<PublicSettings>>());
      final failure = (result as Err<PublicSettings>).failure;
      expect(failure, isA<Network>());
    });

    test('getPublicSettings maps unexpected exception to Unexpected Failure', () async {
      fakeDataSource.errorToThrow = const FormatException('Corrupted response');

      final result = await repository.getPublicSettings();

      expect(result, isA<Err<PublicSettings>>());
      final failure = (result as Err<PublicSettings>).failure;
      expect(failure, isA<Unexpected>());
    });
  });
}
