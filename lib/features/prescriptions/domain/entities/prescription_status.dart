/// Customer-facing Prescription Status representation.
///
/// Handles status normalization and mapping according to AGENTS.md §12.2:
/// - `pending`, `reviewed`, `quoted` -> [PrescriptionStatus.pending] ('قيد الانتظار')
/// - `preparing`, `ready` -> [PrescriptionStatus.preparing] ('جاري التحضير')
/// - `completed` -> [PrescriptionStatus.completed] ('تم التوصيل')
/// - `rejected` -> [PrescriptionStatus.rejected] ('مرفوضة')
/// - unknown -> [PrescriptionStatus.unknown] (safe fallback)
enum PrescriptionStatus {
  pending,
  preparing,
  completed,
  rejected,
  unknown;

  /// Parses and maps a raw backend status string to [PrescriptionStatus].
  ///
  /// Tolerates null, empty strings, case variations, and unhandled server statuses.
  static PrescriptionStatus fromRaw(String? raw) {
    if (raw == null) return PrescriptionStatus.unknown;
    final normalized = raw.trim().toLowerCase();
    switch (normalized) {
      case 'pending':
      case 'reviewed':
      case 'quoted':
        return PrescriptionStatus.pending;
      case 'preparing':
      case 'ready':
        return PrescriptionStatus.preparing;
      case 'completed':
        return PrescriptionStatus.completed;
      case 'rejected':
        return PrescriptionStatus.rejected;
      default:
        return PrescriptionStatus.unknown;
    }
  }

  /// Translation key in ar.json / en.json.
  String get translationKey {
    switch (this) {
      case PrescriptionStatus.pending:
        return 'prescriptions.status_pending';
      case PrescriptionStatus.preparing:
        return 'prescriptions.status_preparing';
      case PrescriptionStatus.completed:
        return 'prescriptions.status_completed';
      case PrescriptionStatus.rejected:
        return 'prescriptions.status_rejected';
      case PrescriptionStatus.unknown:
        return 'prescriptions.status_unknown';
    }
  }

  /// Backwards-compatible alias for [translationKey].
  String get localizationKey => translationKey;
}
