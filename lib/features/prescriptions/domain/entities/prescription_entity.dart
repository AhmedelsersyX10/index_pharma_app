import 'prescription_status.dart';

/// Pure domain entity representing a customer's medical prescription.
class PrescriptionEntity {
  const PrescriptionEntity({
    required this.id,
    required this.prescriptionNumber,
    required this.imageUrl,
    this.customerId,
    this.notes,
    required this.status,
    required this.rawStatus,
    this.pharmacistNotes,
    this.quotedPrice,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
    this.customerName,
    this.customerPhone,
  });

  final String id;
  final String prescriptionNumber;
  final String imageUrl;
  final String? customerId;
  final String? notes;
  final PrescriptionStatus status;
  final String rawStatus;
  final String? pharmacistNotes;
  final double? quotedPrice;
  final String? rejectionReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? customerName;
  final String? customerPhone;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrescriptionEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          prescriptionNumber == other.prescriptionNumber &&
          imageUrl == other.imageUrl &&
          customerId == other.customerId &&
          notes == other.notes &&
          status == other.status &&
          rawStatus == other.rawStatus &&
          pharmacistNotes == other.pharmacistNotes &&
          quotedPrice == other.quotedPrice &&
          rejectionReason == other.rejectionReason &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(
        id,
        prescriptionNumber,
        imageUrl,
        customerId,
        notes,
        status,
        rawStatus,
        pharmacistNotes,
        quotedPrice,
        rejectionReason,
        createdAt,
        updatedAt,
      );

  @override
  String toString() =>
      'PrescriptionEntity(id: $id, prescriptionNumber: $prescriptionNumber, status: $status, quotedPrice: $quotedPrice)';
}
