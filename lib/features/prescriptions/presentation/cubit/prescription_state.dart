import 'package:flutter/foundation.dart';
import '../../domain/entities/prescription_entity.dart';
import '../../domain/entities/prescription_upload_result.dart';

/// Explicit steps for prescription file picking, upload, and submission.
enum PrescriptionUploadStep {
  /// Initial empty state, no image selected.
  empty,

  /// Image has been picked and validated under 5MB.
  selected,

  /// Selected image exceeds the 5MB maximum limit.
  fileSizeExceeded,

  /// Multipart image upload is in progress (POST /prescriptions/upload-image).
  uploading,

  /// Prescription submission is in progress (POST /prescriptions).
  submitting,

  /// Prescription has been submitted successfully to the backend.
  submitted,

  /// Upload or submission failed with a network or server error.
  failure,
}

/// Explicit steps for loading customer prescriptions list.
enum PrescriptionListStep {
  initial,
  loading,
  loaded,
  empty,
  failure,
}

/// Immutable state for the prescription feature.
@immutable
class PrescriptionState {
  const PrescriptionState({
    this.uploadStep = PrescriptionUploadStep.empty,
    this.pickedImagePath,
    this.pickedImageName,
    this.pickedImageSizeBytes,
    this.notes = '',
    this.uploadedResult,
    this.lastSubmittedPrescription,
    this.uploadErrorMessage,
    this.listStep = PrescriptionListStep.initial,
    this.prescriptions = const <PrescriptionEntity>[],
    this.listErrorMessage,
  });

  // --- Upload / Submission fields ---
  final PrescriptionUploadStep uploadStep;
  final String? pickedImagePath;
  final String? pickedImageName;
  final int? pickedImageSizeBytes;
  final String notes;
  final PrescriptionUploadResult? uploadedResult;
  final PrescriptionEntity? lastSubmittedPrescription;
  final String? uploadErrorMessage;

  // --- Prescriptions List fields ---
  final PrescriptionListStep listStep;
  final List<PrescriptionEntity> prescriptions;
  final String? listErrorMessage;

  /// Returns true if an image is currently selected and valid for upload.
  bool get canSubmit =>
      uploadStep == PrescriptionUploadStep.selected &&
      pickedImagePath != null &&
      pickedImagePath!.isNotEmpty;

  /// Formatted size string for display (e.g. "3.2 MB").
  String get formattedPickedFileSize {
    if (pickedImageSizeBytes == null) return '';
    final mb = pickedImageSizeBytes! / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  PrescriptionState copyWith({
    PrescriptionUploadStep? uploadStep,
    String? pickedImagePath,
    bool clearPickedImage = false,
    String? pickedImageName,
    int? pickedImageSizeBytes,
    String? notes,
    PrescriptionUploadResult? uploadedResult,
    bool clearUploadedResult = false,
    PrescriptionEntity? lastSubmittedPrescription,
    String? uploadErrorMessage,
    bool clearUploadError = false,
    PrescriptionListStep? listStep,
    List<PrescriptionEntity>? prescriptions,
    String? listErrorMessage,
    bool clearListError = false,
  }) {
    return PrescriptionState(
      uploadStep: uploadStep ?? this.uploadStep,
      pickedImagePath: clearPickedImage ? null : (pickedImagePath ?? this.pickedImagePath),
      pickedImageName: clearPickedImage ? null : (pickedImageName ?? this.pickedImageName),
      pickedImageSizeBytes:
          clearPickedImage ? null : (pickedImageSizeBytes ?? this.pickedImageSizeBytes),
      notes: notes ?? this.notes,
      uploadedResult: clearUploadedResult ? null : (uploadedResult ?? this.uploadedResult),
      lastSubmittedPrescription:
          lastSubmittedPrescription ?? this.lastSubmittedPrescription,
      uploadErrorMessage:
          clearUploadError ? null : (uploadErrorMessage ?? this.uploadErrorMessage),
      listStep: listStep ?? this.listStep,
      prescriptions: prescriptions ?? this.prescriptions,
      listErrorMessage:
          clearListError ? null : (listErrorMessage ?? this.listErrorMessage),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrescriptionState &&
          runtimeType == other.runtimeType &&
          uploadStep == other.uploadStep &&
          pickedImagePath == other.pickedImagePath &&
          pickedImageName == other.pickedImageName &&
          pickedImageSizeBytes == other.pickedImageSizeBytes &&
          notes == other.notes &&
          uploadedResult == other.uploadedResult &&
          lastSubmittedPrescription == other.lastSubmittedPrescription &&
          uploadErrorMessage == other.uploadErrorMessage &&
          listStep == other.listStep &&
          listEquals(prescriptions, other.prescriptions) &&
          listErrorMessage == other.listErrorMessage;

  @override
  int get hashCode => Object.hash(
        uploadStep,
        pickedImagePath,
        pickedImageName,
        pickedImageSizeBytes,
        notes,
        uploadedResult,
        lastSubmittedPrescription,
        uploadErrorMessage,
        listStep,
        Object.hashAll(prescriptions),
        listErrorMessage,
      );

  @override
  String toString() =>
      'PrescriptionState(uploadStep: $uploadStep, listStep: $listStep, count: ${prescriptions.length})';
}
