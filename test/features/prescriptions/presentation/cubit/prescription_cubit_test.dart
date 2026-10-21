import 'package:flutter_test/flutter_test.dart' hide Timeout;
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/features/prescriptions/domain/entities/prescription_entity.dart';
import 'package:index_pharma/features/prescriptions/domain/entities/prescription_status.dart';
import 'package:index_pharma/features/prescriptions/domain/entities/prescription_upload_result.dart';
import 'package:index_pharma/features/prescriptions/domain/repositories/prescriptions_repository.dart';
import 'package:index_pharma/features/prescriptions/presentation/cubit/prescription_cubit.dart';
import 'package:index_pharma/features/prescriptions/presentation/cubit/prescription_state.dart';

class FakePrescriptionsRepository implements PrescriptionsRepository {
  ApiResult<PrescriptionUploadResult>? uploadResult;
  ApiResult<PrescriptionEntity>? submitResult;
  ApiResult<List<PrescriptionEntity>>? listResult;

  String? lastUploadedPath;
  String? lastUploadedFileName;
  String? lastSubmittedImageUrl;
  String? lastSubmittedNotes;

  @override
  Future<ApiResult<PrescriptionUploadResult>> uploadPrescriptionImage({
    required String filePath,
    required String fileName,
  }) async {
    lastUploadedPath = filePath;
    lastUploadedFileName = fileName;
    return uploadResult!;
  }

  @override
  Future<ApiResult<PrescriptionEntity>> submitPrescription({
    required String imageUrl,
    String? notes,
  }) async {
    lastSubmittedImageUrl = imageUrl;
    lastSubmittedNotes = notes;
    return submitResult!;
  }

  @override
  Future<ApiResult<List<PrescriptionEntity>>> getMyPrescriptions() async {
    return listResult!;
  }
}

void main() {
  group('PrescriptionCubit Tests', () {
    late FakePrescriptionsRepository fakeRepo;
    late PrescriptionCubit cubit;

    setUp(() {
      fakeRepo = FakePrescriptionsRepository();
      cubit = PrescriptionCubit(repository: fakeRepo);
    });

    tearDown(() {
      cubit.close();
    });

    const testEntity = PrescriptionEntity(
      id: 'rx-99',
      prescriptionNumber: 'RX-2026-99',
      imageUrl: '/uploads/prescriptions/file.png',
      status: PrescriptionStatus.pending,
      rawStatus: 'pending',
    );

    const testUploadResult = PrescriptionUploadResult(
      imagePath: '/uploads/prescriptions/file.png',
      filename: 'file.png',
      size: 1024,
    );

    test('initial state has empty uploadStep and initial listStep', () {
      expect(cubit.state.uploadStep, PrescriptionUploadStep.empty);
      expect(cubit.state.listStep, PrescriptionListStep.initial);
      expect(cubit.state.canSubmit, isFalse);
    });

    test('validates 5MB limit: emits fileSizeExceeded when size > 5MB', () {
      const over5Mb = 5 * 1024 * 1024 + 1; // 5MB + 1 byte
      cubit.setPickedImage(
        path: '/tmp/large_rx.jpg',
        name: 'large_rx.jpg',
        sizeBytes: over5Mb,
      );

      expect(cubit.state.uploadStep, PrescriptionUploadStep.fileSizeExceeded);
      expect(cubit.state.pickedImagePath, '/tmp/large_rx.jpg');
      expect(cubit.state.canSubmit, isFalse);
    });

    test('validates 5MB limit: emits selected when size <= 5MB', () {
      const under5Mb = 3 * 1024 * 1024; // 3MB
      cubit.setPickedImage(
        path: '/tmp/valid_rx.jpg',
        name: 'valid_rx.jpg',
        sizeBytes: under5Mb,
      );

      expect(cubit.state.uploadStep, PrescriptionUploadStep.selected);
      expect(cubit.state.pickedImagePath, '/tmp/valid_rx.jpg');
      expect(cubit.state.canSubmit, isTrue);
      expect(cubit.state.formattedPickedFileSize, '3.0 MB');
    });

    test('clearPickedImage resets upload state to empty', () {
      cubit.setPickedImage(
        path: '/tmp/rx.jpg',
        name: 'rx.jpg',
        sizeBytes: 1000,
      );
      expect(cubit.state.uploadStep, PrescriptionUploadStep.selected);

      cubit.clearPickedImage();

      expect(cubit.state.uploadStep, PrescriptionUploadStep.empty);
      expect(cubit.state.pickedImagePath, isNull);
      expect(cubit.state.canSubmit, isFalse);
    });

    test('updateNotes updates notes in state', () {
      cubit.updateNotes('يرجى توفير بديل مصري');
      expect(cubit.state.notes, 'يرجى توفير بديل مصري');
    });

    test('uploadAndSubmit executes upload then submit successfully', () async {
      fakeRepo.uploadResult = const Success(testUploadResult);
      fakeRepo.submitResult = const Success(testEntity);

      cubit.setPickedImage(
        path: '/tmp/rx.png',
        name: 'rx.png',
        sizeBytes: 1024,
      );
      cubit.updateNotes('ملاحظات خاصة');

      final states = <PrescriptionUploadStep>[];
      final subscription = cubit.stream.listen((s) => states.add(s.uploadStep));

      await cubit.uploadAndSubmit();
      await Future<void>.delayed(Duration.zero);

      expect(fakeRepo.lastUploadedPath, '/tmp/rx.png');
      expect(fakeRepo.lastSubmittedImageUrl, '/uploads/prescriptions/file.png');
      expect(fakeRepo.lastSubmittedNotes, 'ملاحظات خاصة');
      expect(cubit.state.uploadStep, PrescriptionUploadStep.submitted);
      expect(cubit.state.lastSubmittedPrescription, testEntity);

      expect(states, contains(PrescriptionUploadStep.uploading));
      expect(states, contains(PrescriptionUploadStep.submitting));
      expect(states.last, PrescriptionUploadStep.submitted);

      await subscription.cancel();
    });

    test('uploadAndSubmit handles upload error properly', () async {
      fakeRepo.uploadResult = const Err(Network(serverMessage: 'تعذر الاتصال بالخادم'));

      cubit.setPickedImage(
        path: '/tmp/rx.png',
        name: 'rx.png',
        sizeBytes: 1024,
      );

      await cubit.uploadAndSubmit();

      expect(cubit.state.uploadStep, PrescriptionUploadStep.failure);
      expect(cubit.state.uploadErrorMessage, 'تعذر الاتصال بالخادم');
    });

    test('uploadAndSubmit handles submit error properly after upload succeeds', () async {
      fakeRepo.uploadResult = const Success(testUploadResult);
      fakeRepo.submitResult = const Err(Server(serverMessage: 'خطأ داخلي في الخادم'));

      cubit.setPickedImage(
        path: '/tmp/rx.png',
        name: 'rx.png',
        sizeBytes: 1024,
      );

      await cubit.uploadAndSubmit();

      expect(cubit.state.uploadStep, PrescriptionUploadStep.failure);
      expect(cubit.state.uploadErrorMessage, 'خطأ داخلي في الخادم');
    });

    test('loadMyPrescriptions loads list successfully', () async {
      fakeRepo.listResult = const Success([testEntity]);

      await cubit.loadMyPrescriptions();

      expect(cubit.state.listStep, PrescriptionListStep.loaded);
      expect(cubit.state.prescriptions.length, 1);
      expect(cubit.state.prescriptions.first.id, 'rx-99');
    });

    test('loadMyPrescriptions emits empty state when list is empty', () async {
      fakeRepo.listResult = const Success([]);

      await cubit.loadMyPrescriptions();

      expect(cubit.state.listStep, PrescriptionListStep.empty);
      expect(cubit.state.prescriptions, isEmpty);
    });

    test('loadMyPrescriptions emits failure on error', () async {
      fakeRepo.listResult = const Err(Timeout(serverMessage: 'انتهت مهلة الطلب'));

      await cubit.loadMyPrescriptions();

      expect(cubit.state.listStep, PrescriptionListStep.failure);
      expect(cubit.state.listErrorMessage, 'انتهت مهلة الطلب');
    });
  });
}
