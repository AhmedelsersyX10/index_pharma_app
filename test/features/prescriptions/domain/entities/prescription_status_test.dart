import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/features/prescriptions/domain/entities/prescription_status.dart';

void main() {
  group('PrescriptionStatus mapping tests', () {
    test('maps pending, reviewed, and quoted to PrescriptionStatus.pending', () {
      expect(PrescriptionStatus.fromRaw('pending'), PrescriptionStatus.pending);
      expect(PrescriptionStatus.fromRaw('reviewed'), PrescriptionStatus.pending);
      expect(PrescriptionStatus.fromRaw('quoted'), PrescriptionStatus.pending);
      expect(PrescriptionStatus.fromRaw('PENDING'), PrescriptionStatus.pending);
      expect(PrescriptionStatus.fromRaw(' Quoted '), PrescriptionStatus.pending);
    });

    test('maps preparing and ready to PrescriptionStatus.preparing', () {
      expect(PrescriptionStatus.fromRaw('preparing'), PrescriptionStatus.preparing);
      expect(PrescriptionStatus.fromRaw('ready'), PrescriptionStatus.preparing);
      expect(PrescriptionStatus.fromRaw('PREPARING'), PrescriptionStatus.preparing);
      expect(PrescriptionStatus.fromRaw(' Ready '), PrescriptionStatus.preparing);
    });

    test('maps completed to PrescriptionStatus.completed', () {
      expect(PrescriptionStatus.fromRaw('completed'), PrescriptionStatus.completed);
      expect(PrescriptionStatus.fromRaw('COMPLETED'), PrescriptionStatus.completed);
      expect(PrescriptionStatus.fromRaw(' completed '), PrescriptionStatus.completed);
    });

    test('maps rejected to PrescriptionStatus.rejected', () {
      expect(PrescriptionStatus.fromRaw('rejected'), PrescriptionStatus.rejected);
      expect(PrescriptionStatus.fromRaw('REJECTED'), PrescriptionStatus.rejected);
      expect(PrescriptionStatus.fromRaw(' Rejected '), PrescriptionStatus.rejected);
    });

    test('tolerates unknown and null statuses gracefully', () {
      expect(PrescriptionStatus.fromRaw(null), PrescriptionStatus.unknown);
      expect(PrescriptionStatus.fromRaw(''), PrescriptionStatus.unknown);
      expect(PrescriptionStatus.fromRaw('unknown_status_xyz'), PrescriptionStatus.unknown);
      expect(PrescriptionStatus.fromRaw('dispatched'), PrescriptionStatus.unknown);
    });

    test('returns correct translation keys matching OrderStatus pattern', () {
      expect(PrescriptionStatus.pending.translationKey, 'prescriptions.status_pending');
      expect(PrescriptionStatus.preparing.translationKey, 'prescriptions.status_preparing');
      expect(PrescriptionStatus.completed.translationKey, 'prescriptions.status_completed');
      expect(PrescriptionStatus.rejected.translationKey, 'prescriptions.status_rejected');
      expect(PrescriptionStatus.unknown.translationKey, 'prescriptions.status_unknown');
      // Backwards-compatible localizationKey
      expect(PrescriptionStatus.pending.localizationKey, 'prescriptions.status_pending');
    });
  });
}
