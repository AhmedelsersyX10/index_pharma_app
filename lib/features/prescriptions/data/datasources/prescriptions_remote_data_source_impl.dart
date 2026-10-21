import 'package:dio/dio.dart';
import 'package:index_pharma/core/network/api_client.dart';
import '../models/prescription_model.dart';
import '../models/prescription_upload_response_model.dart';
import 'prescriptions_remote_data_source.dart';

/// Implementation of [PrescriptionsRemoteDataSource] using [Dio].
class PrescriptionsRemoteDataSourceImpl implements PrescriptionsRemoteDataSource {
  const PrescriptionsRemoteDataSourceImpl({
    required Dio dio,
  }) : _dio = dio;

  final Dio _dio;

  @override
  Future<PrescriptionUploadResponseModel> uploadPrescriptionImage({
    required String filePath,
    required String fileName,
  }) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
    });

    final response = await _dio.post<dynamic>(
      '/prescriptions/upload-image',
      data: formData,
      options: ApiClient.uploadOptions,
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return PrescriptionUploadResponseModel.fromJson(data);
    } else if (data is Map) {
      return PrescriptionUploadResponseModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw const FormatException('Invalid upload response format from server');
  }

  @override
  Future<PrescriptionModel> submitPrescription({
    required String imageUrl,
    String? notes,
  }) async {
    final payload = <String, dynamic>{
      'imageUrl': imageUrl,
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    };

    final response = await _dio.post<dynamic>(
      '/prescriptions',
      data: payload,
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final prescriptionData = data['data'];
      if (prescriptionData is Map<String, dynamic>) {
        return PrescriptionModel.fromJson(prescriptionData);
      } else if (prescriptionData is Map) {
        return PrescriptionModel.fromJson(
          Map<String, dynamic>.from(prescriptionData),
        );
      }
      return PrescriptionModel.fromJson(data);
    } else if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      if (map['data'] is Map) {
        return PrescriptionModel.fromJson(
          Map<String, dynamic>.from(map['data'] as Map),
        );
      }
      return PrescriptionModel.fromJson(map);
    }

    throw const FormatException('Invalid submit response format from server');
  }

  @override
  Future<List<PrescriptionModel>> getMyPrescriptions() async {
    final response = await _dio.get<dynamic>('/prescriptions/my');

    final data = response.data;
    List<dynamic>? list;

    if (data is Map<String, dynamic>) {
      final rawData = data['data'];
      if (rawData is List) {
        list = rawData;
      }
    } else if (data is Map) {
      final rawData = data['data'];
      if (rawData is List) {
        list = rawData;
      }
    } else if (data is List) {
      list = data;
    }

    if (list != null) {
      return list
          .whereType<Map>()
          .map((item) =>
              PrescriptionModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    throw const FormatException('Invalid prescriptions list response format');
  }
}
