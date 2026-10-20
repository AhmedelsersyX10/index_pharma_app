import 'package:index_pharma/core/widgets/app_badges.dart';

/// Clinical and customer-facing order status representation.
/// Corresponds to documented statuses in AGENTS.md §12.1 and Stitch C6/F8 status matrices.
enum OrderStatus {
  pending,
  processing,
  completed,
  delivered,
  cancelled,
  unknown;

  /// Safely parses raw status string from server without throwing on unknown values.
  static OrderStatus fromString(String? rawStatus) {
    if (rawStatus == null) return OrderStatus.unknown;
    switch (rawStatus.trim().toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'processing':
        return OrderStatus.processing;
      case 'completed':
        return OrderStatus.completed;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.unknown;
    }
  }

  /// Translation key in ar.json / en.json.
  String get translationKey {
    switch (this) {
      case OrderStatus.pending:
        return 'orders.status_pending';
      case OrderStatus.processing:
        return 'orders.status_processing';
      case OrderStatus.completed:
        return 'orders.status_completed';
      case OrderStatus.delivered:
        return 'orders.status_delivered';
      case OrderStatus.cancelled:
        return 'orders.status_cancelled';
      case OrderStatus.unknown:
        return 'orders.status_unknown';
    }
  }

  /// Corresponding WCAG AAA tone for [AppBadge].
  AppBadgeTone get badgeTone {
    switch (this) {
      case OrderStatus.pending:
        return AppBadgeTone.warning;
      case OrderStatus.processing:
        return AppBadgeTone.info;
      case OrderStatus.completed:
        return AppBadgeTone.purple;
      case OrderStatus.delivered:
        return AppBadgeTone.success;
      case OrderStatus.cancelled:
        return AppBadgeTone.error;
      case OrderStatus.unknown:
        return AppBadgeTone.neutral;
    }
  }

  /// Whether the order is in an active/in-progress pipeline.
  bool get isActive =>
      this == OrderStatus.pending ||
      this == OrderStatus.processing ||
      this == OrderStatus.completed;

  /// Whether the order has finished its lifecycle.
  bool get isPast =>
      this == OrderStatus.delivered || this == OrderStatus.cancelled;
}
