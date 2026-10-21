import 'package:index_pharma/core/network/api_result.dart';
import '../entities/prescription_entity.dart';
import '../entities/prescription_upload_result.dart';

/// Contract for Prescription operations.
abstract class PrescriptionsRepository {
  /// Uploads a prescription image to `POST /prescriptions/upload-image`.
  Future<ApiResult<PrescriptionUploadResult>> uploadPrescriptionImage({
    required String filePath,
    required String fileName,
  });

  /// Submits a prescription record to `POST /prescriptions`.
  Future<ApiResult<PrescriptionEntity>> submitPrescription({
    required String imageUrl,
    String? notes,
  });

  /// Fetches the authenticated customer's prescriptions from `GET /prescriptions/my`.
  Future<ApiResult<List<PrescriptionEntity>>> getMyPrescriptions();
}
