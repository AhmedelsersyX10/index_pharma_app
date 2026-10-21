import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:index_pharma/core/network/api_result.dart';
import '../../domain/repositories/prescriptions_repository.dart';
import 'prescription_state.dart';

/// Cubit managing prescription image picking, 5MB validation, upload, submission, and list state.
class PrescriptionCubit extends Cubit<PrescriptionState> {
  PrescriptionCubit({
    required PrescriptionsRepository repository,
    ImagePicker? imagePicker,
  })  : _repository = repository,
        _imagePicker = imagePicker ?? ImagePicker(),
        super(const PrescriptionState());

  final PrescriptionsRepository _repository;
  final ImagePicker _imagePicker;

  /// Maximum allowed prescription file size: 5 Megabytes (5 * 1024 * 1024 bytes).
  static const int maxFileSizeBytes = 5 * 1024 * 1024;

  /// Picks an image from either camera or gallery, validates file size <= 5MB,
  /// and updates state accordingly.
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: source,
        imageQuality: 90,
      );

      if (file == null) {
        // User cancelled selection; keep existing state.
        return;
      }

      final int size = await file.length();
      if (size > maxFileSizeBytes) {
        emit(
          state.copyWith(
            uploadStep: PrescriptionUploadStep.fileSizeExceeded,
            pickedImagePath: file.path,
            pickedImageName: file.name,
            pickedImageSizeBytes: size,
            clearUploadError: true,
          ),
        );
      } else {
        emit(
          state.copyWith(
            uploadStep: PrescriptionUploadStep.selected,
            pickedImagePath: file.path,
            pickedImageName: file.name,
            pickedImageSizeBytes: size,
            clearUploadError: true,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          uploadStep: PrescriptionUploadStep.failure,
          uploadErrorMessage: e.toString(),
        ),
      );
    }
  }

  /// Sets directly picked image data (useful for testing or drag-and-drop).
  void setPickedImage({
    required String path,
    required String name,
    required int sizeBytes,
  }) {
    if (sizeBytes > maxFileSizeBytes) {
      emit(
        state.copyWith(
          uploadStep: PrescriptionUploadStep.fileSizeExceeded,
          pickedImagePath: path,
          pickedImageName: name,
          pickedImageSizeBytes: sizeBytes,
          clearUploadError: true,
        ),
      );
    } else {
      emit(
        state.copyWith(
          uploadStep: PrescriptionUploadStep.selected,
          pickedImagePath: path,
          pickedImageName: name,
          pickedImageSizeBytes: sizeBytes,
          clearUploadError: true,
        ),
      );
    }
  }

  /// Updates the optional notes string.
  void updateNotes(String notes) {
    emit(state.copyWith(notes: notes));
  }

  /// Clears the picked image and resets upload status to [PrescriptionUploadStep.empty].
  void clearPickedImage() {
    emit(
      state.copyWith(
        uploadStep: PrescriptionUploadStep.empty,
        clearPickedImage: true,
        clearUploadedResult: true,
        clearUploadError: true,
      ),
    );
  }

  /// Uploads the selected image file and submits the prescription.
  Future<void> uploadAndSubmit() async {
    final imagePath = state.pickedImagePath;
    final imageName = state.pickedImageName ?? 'prescription.jpg';

    if (imagePath == null || imagePath.isEmpty) {
      emit(
        state.copyWith(
          uploadStep: PrescriptionUploadStep.failure,
          uploadErrorMessage: 'يرجى اختيار صورة الروشتة أولاً',
        ),
      );
      return;
    }

    if ((state.pickedImageSizeBytes ?? 0) > maxFileSizeBytes) {
      emit(
        state.copyWith(
          uploadStep: PrescriptionUploadStep.fileSizeExceeded,
        ),
      );
      return;
    }

    // Step 1: Upload image file
    emit(
      state.copyWith(
        uploadStep: PrescriptionUploadStep.uploading,
        clearUploadError: true,
      ),
    );

    final uploadResult = await _repository.uploadPrescriptionImage(
      filePath: imagePath,
      fileName: imageName,
    );

    switch (uploadResult) {
      case Err(:final failure):
        emit(
          state.copyWith(
            uploadStep: PrescriptionUploadStep.failure,
            uploadErrorMessage: failure.serverMessage ?? 'تعذر رفع صورة الروشتة',
          ),
        );
        return;
      case Success(:final data):
        // Step 2: Submit prescription with relative path
        emit(
          state.copyWith(
            uploadStep: PrescriptionUploadStep.submitting,
            uploadedResult: data,
          ),
        );

        final submitResult = await _repository.submitPrescription(
          imageUrl: data.imagePath,
          notes: state.notes.trim().isNotEmpty ? state.notes.trim() : null,
        );

        switch (submitResult) {
          case Err(:final failure):
            emit(
              state.copyWith(
                uploadStep: PrescriptionUploadStep.failure,
                uploadErrorMessage: failure.serverMessage ?? 'تعذر إرسال الروشتة للمراجعة',
              ),
            );
          case Success(:final data):
            // Prepend new prescription to existing list if available
            final updatedList = [data, ...state.prescriptions];
            emit(
              state.copyWith(
                uploadStep: PrescriptionUploadStep.submitted,
                lastSubmittedPrescription: data,
                prescriptions: updatedList,
                listStep: PrescriptionListStep.loaded,
                clearUploadError: true,
              ),
            );
        }
    }
  }

  /// Loads the customer's prescription history (`GET /prescriptions/my`).
  Future<void> loadMyPrescriptions() async {
    emit(
      state.copyWith(
        listStep: PrescriptionListStep.loading,
        clearListError: true,
      ),
    );

    final result = await _repository.getMyPrescriptions();

    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            listStep: PrescriptionListStep.failure,
            listErrorMessage: failure.serverMessage ?? 'تعذر تحميل قائمة الروشتات',
          ),
        );
      case Success(:final data):
        if (data.isEmpty) {
          emit(
            state.copyWith(
              listStep: PrescriptionListStep.empty,
              prescriptions: const [],
            ),
          );
        } else {
          emit(
            state.copyWith(
              listStep: PrescriptionListStep.loaded,
              prescriptions: data,
            ),
          );
        }
    }
  }

  /// Resets the upload form for a new upload.
  void resetUploadFlow() {
    emit(
      state.copyWith(
        uploadStep: PrescriptionUploadStep.empty,
        clearPickedImage: true,
        clearUploadedResult: true,
        clearUploadError: true,
        notes: '',
      ),
    );
  }
}
