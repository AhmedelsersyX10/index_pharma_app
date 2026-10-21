import 'package:dio/dio.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/core/network/error_mapper.dart';
import '../../domain/entities/prescription_entity.dart';
import '../../domain/entities/prescription_upload_result.dart';
import '../../domain/repositories/prescriptions_repository.dart';
import '../datasources/prescriptions_remote_data_source.dart';

/// Implementation of [PrescriptionsRepository] using [PrescriptionsRemoteDataSource].
class PrescriptionsRepositoryImpl implements PrescriptionsRepository {
  const PrescriptionsRepositoryImpl({
    required PrescriptionsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final PrescriptionsRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<PrescriptionUploadResult>> uploadPrescriptionImage({
    required String filePath,
    required String fileName,
  }) async {
    try {
      final responseModel = await _remoteDataSource.uploadPrescriptionImage(
        filePath: filePath,
        fileName: fileName,
      );
      return Success(responseModel.toEntity());
    } on DioException catch (e) {
      return Err(e.toFailure());
    } catch (e) {
      return Err(Unexpected(serverMessage: e.toString()));
    }
  }

  @override
  Future<ApiResult<PrescriptionEntity>> submitPrescription({
    required String imageUrl,
    String? notes,
  }) async {
    try {
      final responseModel = await _remoteDataSource.submitPrescription(
        imageUrl: imageUrl,
        notes: notes,
      );
      return Success(responseModel.toEntity());
    } on DioException catch (e) {
      return Err(e.toFailure());
    } catch (e) {
      return Err(Unexpected(serverMessage: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<PrescriptionEntity>>> getMyPrescriptions() async {
    try {
      final list = await _remoteDataSource.getMyPrescriptions();
      return Success(list.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Err(e.toFailure());
    } catch (e) {
      return Err(Unexpected(serverMessage: e.toString()));
    }
  }
}
