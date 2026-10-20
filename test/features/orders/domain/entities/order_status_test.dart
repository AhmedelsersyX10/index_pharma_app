import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/widgets/app_badges.dart';
import 'package:index_pharma/features/orders/domain/entities/order_status.dart';

void main() {
  group('OrderStatus Enum Tests', () {
    test('fromString parses documented statuses case-insensitively', () {
      expect(OrderStatus.fromString('pending'), OrderStatus.pending);
      expect(OrderStatus.fromString('PENDING'), OrderStatus.pending);
      expect(OrderStatus.fromString('processing'), OrderStatus.processing);
      expect(OrderStatus.fromString('Processing'), OrderStatus.processing);
      expect(OrderStatus.fromString('completed'), OrderStatus.completed);
      expect(OrderStatus.fromString('COMPLETED'), OrderStatus.completed);
      expect(OrderStatus.fromString('delivered'), OrderStatus.delivered);
      expect(OrderStatus.fromString('Delivered'), OrderStatus.delivered);
      expect(OrderStatus.fromString('cancelled'), OrderStatus.cancelled);
      expect(OrderStatus.fromString('CANCELLED'), OrderStatus.cancelled);
    });

    test('fromString safely returns OrderStatus.unknown for unknown strings or null', () {
      expect(OrderStatus.fromString(null), OrderStatus.unknown);
      expect(OrderStatus.fromString(''), OrderStatus.unknown);
      expect(OrderStatus.fromString('unknown_status_xyz'), OrderStatus.unknown);
      expect(OrderStatus.fromString('shipped'), OrderStatus.unknown);
      expect(OrderStatus.fromString('refunded'), OrderStatus.unknown);
    });

    test('badgeTone maps each status to correct WCAG AAA tone', () {
      expect(OrderStatus.pending.badgeTone, AppBadgeTone.warning);
      expect(OrderStatus.processing.badgeTone, AppBadgeTone.info);
      expect(OrderStatus.completed.badgeTone, AppBadgeTone.purple);
      expect(OrderStatus.delivered.badgeTone, AppBadgeTone.success);
      expect(OrderStatus.cancelled.badgeTone, AppBadgeTone.error);
      expect(OrderStatus.unknown.badgeTone, AppBadgeTone.neutral);
    });

    test('translationKey returns valid translation keys for each status', () {
      expect(OrderStatus.pending.translationKey, 'orders.status_pending');
      expect(OrderStatus.processing.translationKey, 'orders.status_processing');
      expect(OrderStatus.completed.translationKey, 'orders.status_completed');
      expect(OrderStatus.delivered.translationKey, 'orders.status_delivered');
      expect(OrderStatus.cancelled.translationKey, 'orders.status_cancelled');
      expect(OrderStatus.unknown.translationKey, 'orders.status_unknown');
    });

    test('isActive and isPast lifecycle categorizations work accurately', () {
      expect(OrderStatus.pending.isActive, isTrue);
      expect(OrderStatus.processing.isActive, isTrue);
      expect(OrderStatus.completed.isActive, isTrue);
      expect(OrderStatus.delivered.isActive, isFalse);
      expect(OrderStatus.cancelled.isActive, isFalse);

      expect(OrderStatus.delivered.isPast, isTrue);
      expect(OrderStatus.cancelled.isPast, isTrue);
      expect(OrderStatus.pending.isPast, isFalse);
      expect(OrderStatus.processing.isPast, isFalse);
      expect(OrderStatus.completed.isPast, isFalse);
    });
  });
}
