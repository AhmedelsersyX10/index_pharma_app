import '../../domain/entities/prescription_upload_result.dart';

/// DTO for the response from `POST /prescriptions/upload-image`.
class PrescriptionUploadResponseModel {
  const PrescriptionUploadResponseModel({
    required this.image,
    this.filename,
    this.mimeType,
    this.size,
    this.extension,
  });

  final String image;
  final String? filename;
  final String? mimeType;
  final int? size;
  final String? extension;

  factory PrescriptionUploadResponseModel.fromJson(Map<String, dynamic> json) {
    // If the server wraps data in `data`, unpack it
    final payload = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : (json['data'] is Map)
            ? Map<String, dynamic>.from(json['data'] as Map)
            : json;

    return PrescriptionUploadResponseModel(
      image: (payload['image'] as String?)?.trim() ?? '',
      filename: payload['filename'] as String?,
      mimeType: payload['mimeType'] as String?,
      size: payload['size'] is num ? (payload['size'] as num).toInt() : null,
      extension: payload['extension'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'image': image,
        if (filename != null) 'filename': filename,
        if (mimeType != null) 'mimeType': mimeType,
        if (size != null) 'size': size,
        if (extension != null) 'extension': extension,
      };

  PrescriptionUploadResult toEntity() => PrescriptionUploadResult(
        imagePath: image,
        filename: filename,
        size: size,
        mimeType: mimeType,
      );
}
