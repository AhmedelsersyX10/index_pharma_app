/// Result of a successful prescription image upload.
class PrescriptionUploadResult {
  const PrescriptionUploadResult({
    required this.imagePath,
    this.filename,
    this.size,
    this.mimeType,
  });

  /// The relative image path on the server (e.g. `/uploads/prescriptions/...`).
  final String imagePath;

  /// Original or assigned filename on the server.
  final String? filename;

  /// Size of the uploaded file in bytes.
  final int? size;

  /// MIME type of the uploaded file.
  final String? mimeType;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrescriptionUploadResult &&
          runtimeType == other.runtimeType &&
          imagePath == other.imagePath &&
          filename == other.filename &&
          size == other.size &&
          mimeType == other.mimeType;

  @override
  int get hashCode => Object.hash(imagePath, filename, size, mimeType);

  @override
  String toString() =>
      'PrescriptionUploadResult(imagePath: $imagePath, filename: $filename, size: $size)';
}
