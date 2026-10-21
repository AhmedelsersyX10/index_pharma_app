import '../models/prescription_model.dart';
import '../models/prescription_upload_response_model.dart';

/// Contract for Prescription remote data operations.
abstract class PrescriptionsRemoteDataSource {
  /// Uploads an image file to `/prescriptions/upload-image` with 60s timeout options.
  Future<PrescriptionUploadResponseModel> uploadPrescriptionImage({
    required String filePath,
    required String fileName,
  });

  /// Submits a prescription payload to `/prescriptions`.
  Future<PrescriptionModel> submitPrescription({
    required String imageUrl,
    String? notes,
  });

  /// Fetches the customer's prescriptions from `/prescriptions/my`.
  Future<List<PrescriptionModel>> getMyPrescriptions();
}
