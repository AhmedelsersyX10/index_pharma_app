import '../../domain/entities/prescription_entity.dart';
import '../../domain/entities/prescription_status.dart';

/// DTO for a prescription from the backend API.
class PrescriptionModel {
  const PrescriptionModel({
    required this.id,
    required this.prescriptionNumber,
    required this.imageUrl,
    this.customerId,
    this.notes,
    required this.status,
    this.pharmacistId,
    this.pharmacistNotes,
    this.quotedPrice,
    this.customerResponse,
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
  final String status;
  final String? pharmacistId;
  final String? pharmacistNotes;
  final double? quotedPrice;
  final String? customerResponse;
  final String? rejectionReason;
  final String? createdAt;
  final String? updatedAt;
  final String? customerName;
  final String? customerPhone;

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    // Read customer details if available
    String? custName;
    String? custPhone;
    if (json['customer'] is Map) {
      final cust = json['customer'] as Map;
      custName = cust['name']?.toString();
      custPhone = cust['phone']?.toString();
    }

    double? parsePrice(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return PrescriptionModel(
      id: (json['id'] ?? '').toString(),
      prescriptionNumber: (json['prescriptionNumber'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      customerId: json['customerId']?.toString(),
      notes: json['notes'] as String?,
      status: (json['status'] ?? 'pending').toString(),
      pharmacistId: json['pharmacistId']?.toString(),
      pharmacistNotes: json['pharmacistNotes'] as String?,
      quotedPrice: parsePrice(json['quotedPrice']),
      customerResponse: json['customerResponse'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      customerName: custName,
      customerPhone: custPhone,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'prescriptionNumber': prescriptionNumber,
        'imageUrl': imageUrl,
        if (customerId != null) 'customerId': customerId,
        if (notes != null) 'notes': notes,
        'status': status,
        if (pharmacistId != null) 'pharmacistId': pharmacistId,
        if (pharmacistNotes != null) 'pharmacistNotes': pharmacistNotes,
        if (quotedPrice != null) 'quotedPrice': quotedPrice,
        if (customerResponse != null) 'customerResponse': customerResponse,
        if (rejectionReason != null) 'rejectionReason': rejectionReason,
        if (createdAt != null) 'createdAt': createdAt,
        if (updatedAt != null) 'updatedAt': updatedAt,
      };

  PrescriptionEntity toEntity() {
    DateTime? parseDate(String? str) {
      if (str == null || str.isEmpty) return null;
      return DateTime.tryParse(str);
    }

    return PrescriptionEntity(
      id: id,
      prescriptionNumber: prescriptionNumber,
      imageUrl: imageUrl,
      customerId: customerId,
      notes: notes,
      status: PrescriptionStatus.fromRaw(status),
      rawStatus: status,
      pharmacistNotes: pharmacistNotes,
      quotedPrice: quotedPrice,
      rejectionReason: rejectionReason,
      createdAt: parseDate(createdAt),
      updatedAt: parseDate(updatedAt),
      customerName: customerName,
      customerPhone: customerPhone,
    );
  }
}
