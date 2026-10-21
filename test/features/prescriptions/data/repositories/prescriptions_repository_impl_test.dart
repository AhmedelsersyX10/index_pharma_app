import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart' hide Timeout;
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/features/prescriptions/data/datasources/prescriptions_remote_data_source.dart';
import 'package:index_pharma/features/prescriptions/data/models/prescription_model.dart';
import 'package:index_pharma/features/prescriptions/data/models/prescription_upload_response_model.dart';
import 'package:index_pharma/features/prescriptions/data/repositories/prescriptions_repository_impl.dart';
import 'package:index_pharma/features/prescriptions/domain/entities/prescription_entity.dart';
import 'package:index_pharma/features/prescriptions/domain/entities/prescription_status.dart';
import 'package:index_pharma/features/prescriptions/domain/entities/prescription_upload_result.dart';

class FakePrescriptionsRemoteDataSource implements PrescriptionsRemoteDataSource {
  PrescriptionUploadResponseModel? uploadResultToReturn;
  PrescriptionModel? submitResultToReturn;
  List<PrescriptionModel>? listResultToReturn;
  Exception? exceptionToThrow;

  String? lastUploadedPath;
  String? lastUploadedFileName;
  String? lastSubmittedImageUrl;
  String? lastSubmittedNotes;

  @override
  Future<PrescriptionUploadResponseModel> uploadPrescriptionImage({
    required String filePath,
    required String fileName,
  }) async {
    lastUploadedPath = filePath;
    lastUploadedFileName = fileName;
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return uploadResultToReturn!;
  }

  @override
  Future<PrescriptionModel> submitPrescription({
    required String imageUrl,
    String? notes,
  }) async {
    lastSubmittedImageUrl = imageUrl;
    lastSubmittedNotes = notes;
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return submitResultToReturn!;
  }

  @override
  Future<List<PrescriptionModel>> getMyPrescriptions() async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return listResultToReturn!;
  }
}

void main() {
  group('PrescriptionsRepositoryImpl Tests', () {
    late FakePrescriptionsRemoteDataSource fakeDataSource;
    late PrescriptionsRepositoryImpl repository;

    setUp(() {
      fakeDataSource = FakePrescriptionsRemoteDataSource();
      repository = PrescriptionsRepositoryImpl(remoteDataSource: fakeDataSource);
    });

    const testUploadModel = PrescriptionUploadResponseModel(
      image: '/uploads/prescriptions/rx-123.png',
      filename: 'rx-123.png',
      size: 50000,
      mimeType: 'image/png',
    );

    const testPrescriptionModel = PrescriptionModel(
      id: 'rx-77',
      prescriptionNumber: 'RX-2026-001',
      imageUrl: '/uploads/prescriptions/rx-123.png',
      status: 'pending',
      notes: 'بديل إذا لم يتوفر الأصلي',
    );

    test('uploadPrescriptionImage returns Success with PrescriptionUploadResult on success', () async {
      fakeDataSource.uploadResultToReturn = testUploadModel;

      final result = await repository.uploadPrescriptionImage(
        filePath: '/tmp/rx.jpg',
        fileName: 'rx.jpg',
      );

      expect(fakeDataSource.lastUploadedPath, '/tmp/rx.jpg');
      expect(fakeDataSource.lastUploadedFileName, 'rx.jpg');
      expect(result, isA<Success<PrescriptionUploadResult>>());
      final data = (result as Success<PrescriptionUploadResult>).data;
      expect(data.imagePath, '/uploads/prescriptions/rx-123.png');
      expect(data.filename, 'rx-123.png');
      expect(data.size, 50000);
    });

    test('uploadPrescriptionImage returns Err on DioException', () async {
      fakeDataSource.exceptionToThrow = DioException(
        requestOptions: RequestOptions(path: '/prescriptions/upload-image'),
        type: DioExceptionType.connectionTimeout,
      );

      final result = await repository.uploadPrescriptionImage(
        filePath: '/tmp/rx.jpg',
        fileName: 'rx.jpg',
      );

      expect(result, isA<Err<PrescriptionUploadResult>>());
      final failure = (result as Err<PrescriptionUploadResult>).failure;
      expect(failure, isA<Timeout>());
    });

    test('submitPrescription returns Success with PrescriptionEntity on success', () async {
      fakeDataSource.submitResultToReturn = testPrescriptionModel;

      final result = await repository.submitPrescription(
        imageUrl: '/uploads/prescriptions/rx-123.png',
        notes: 'بديل إذا لم يتوفر الأصلي',
      );

      expect(fakeDataSource.lastSubmittedImageUrl, '/uploads/prescriptions/rx-123.png');
      expect(fakeDataSource.lastSubmittedNotes, 'بديل إذا لم يتوفر الأصلي');
      expect(result, isA<Success<PrescriptionEntity>>());
      final data = (result as Success<PrescriptionEntity>).data;
      expect(data.id, 'rx-77');
      expect(data.prescriptionNumber, 'RX-2026-001');
      expect(data.status, PrescriptionStatus.pending);
    });

    test('getMyPrescriptions returns mapped entities on success', () async {
      fakeDataSource.listResultToReturn = [testPrescriptionModel];

      final result = await repository.getMyPrescriptions();

      expect(result, isA<Success<List<PrescriptionEntity>>>());
      final list = (result as Success<List<PrescriptionEntity>>).data;
      expect(list.length, 1);
      expect(list.first.id, 'rx-77');
      expect(list.first.status, PrescriptionStatus.pending);
    });

    test('getMyPrescriptions returns Err on server failure', () async {
      fakeDataSource.exceptionToThrow = DioException(
        requestOptions: RequestOptions(path: '/prescriptions/my'),
        response: Response(
          requestOptions: RequestOptions(path: '/prescriptions/my'),
          statusCode: 500,
          data: {'message': 'خطأ في السيرفر'},
        ),
      );

      final result = await repository.getMyPrescriptions();

      expect(result, isA<Err<List<PrescriptionEntity>>>());
      final failure = (result as Err<List<PrescriptionEntity>>).failure;
      expect(failure, isA<Server>());
      expect(failure.serverMessage, 'خطأ في السيرفر');
    });
  });
}
