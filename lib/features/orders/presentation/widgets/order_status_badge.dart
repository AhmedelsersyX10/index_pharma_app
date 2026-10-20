import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/widgets/app_badges.dart';
import '../../domain/entities/order_status.dart';

/// Clinical Status Badge for orders based on Stitch C6 / F8 matrices.
class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({
    super.key,
    required this.status,
    this.padding,
  });

  final OrderStatus status;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final label = status.translationKey.tr();
    final icon = switch (status) {
      OrderStatus.pending => const Icon(Icons.schedule_rounded, size: 14),
      OrderStatus.processing => const Icon(Icons.sync_rounded, size: 14),
      OrderStatus.completed => const Icon(Icons.inventory_2_outlined, size: 14),
      OrderStatus.delivered => const Icon(Icons.done_all_rounded, size: 14),
      OrderStatus.cancelled => const Icon(Icons.close_rounded, size: 14),
      OrderStatus.unknown => const Icon(Icons.info_outline_rounded, size: 14),
    };

    return AppBadge(
      label: label,
      tone: status.badgeTone,
      icon: icon,
      padding: padding,
    );
  }
}
