import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/theme.dart';
import '../../domain/entities/order_status.dart';

/// Vertical timeline displaying real order progression stages (Stitch C5).
/// Only shows documented statuses without synthetic steps or timestamps.
class OrderTimelineView extends StatelessWidget {
  const OrderTimelineView({
    super.key,
    required this.status,
  });

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    if (status == OrderStatus.cancelled) {
      return _buildCancelledTimeline(context);
    }
    return _buildNormalTimeline(context);
  }

  Widget _buildNormalTimeline(BuildContext context) {
    final stages = [
      (
        status: OrderStatus.pending,
        titleKey: 'orders.status_pending',
        descKey: 'orders.timeline_pending_desc',
        icon: Icons.receipt_long_rounded,
      ),
      (
        status: OrderStatus.processing,
        titleKey: 'orders.status_processing',
        descKey: 'orders.timeline_processing_desc',
        icon: Icons.sync_rounded,
      ),
      (
        status: OrderStatus.completed,
        titleKey: 'orders.status_completed',
        descKey: 'orders.timeline_completed_desc',
        icon: Icons.inventory_2_outlined,
      ),
      (
        status: OrderStatus.delivered,
        titleKey: 'orders.status_delivered',
        descKey: 'orders.timeline_delivered_desc',
        icon: Icons.sports_motorsports_rounded,
      ),
    ];

    final currentIndex = _getStatusIndex(status);

    return Column(
      children: List.generate(stages.length, (index) {
        final stage = stages[index];
        final isCompleted = index < currentIndex;
        final isActive = index == currentIndex;
        final isLast = index == stages.length - 1;

        return _TimelineNode(
          title: stage.titleKey.tr(),
          description: stage.descKey.tr(),
          icon: stage.icon,
          isCompleted: isCompleted,
          isActive: isActive,
          isLast: isLast,
        );
      }),
    );
  }

  Widget _buildCancelledTimeline(BuildContext context) {
    return Column(
      children: [
        _TimelineNode(
          title: 'orders.status_pending'.tr(),
          description: 'orders.timeline_pending_desc'.tr(),
          icon: Icons.check_rounded,
          isCompleted: true,
          isActive: false,
          isLast: false,
        ),
        _TimelineNode(
          title: 'orders.status_cancelled'.tr(),
          description: 'orders.timeline_cancelled_desc'.tr(),
          icon: Icons.close_rounded,
          isCompleted: false,
          isActive: true,
          isLast: true,
          isCancelled: true,
        ),
      ],
    );
  }

  int _getStatusIndex(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.processing:
        return 1;
      case OrderStatus.completed:
        return 2;
      case OrderStatus.delivered:
        return 3;
      case OrderStatus.cancelled:
      case OrderStatus.unknown:
        return 0;
    }
  }
}

class _TimelineNode extends StatelessWidget {
  const _TimelineNode({
    required this.title,
    required this.description,
    required this.icon,
    required this.isCompleted,
    required this.isActive,
    required this.isLast,
    this.isCancelled = false,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool isCompleted;
  final bool isActive;
  final bool isLast;
  final bool isCancelled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (Color circleBg, Color iconColor, Color lineColor) = _resolveColors(colors);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicator & vertical connecting line
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: circleBg,
                    shape: BoxShape.circle,
                    border: isActive && !isCancelled
                        ? Border.all(color: colors.brandMintBorder, width: 3)
                        : null,
                    boxShadow: isActive ? context.shadowsLevel1 : null,
                  ),
                  child: Center(
                    child: Icon(
                      isCompleted ? Icons.check_rounded : icon,
                      size: 16,
                      color: iconColor,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: lineColor,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.spaceSm),

          // Stage Title & Description
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                          color: isCancelled
                              ? colors.medicalRed
                              : (isActive ? colors.primary : colors.onSurface),
                        ),
                      ),
                      if (isActive && !isCancelled) ...[
                        const SizedBox(width: AppSpacing.spaceXs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.brandMintSurface,
                            borderRadius: BorderRadius.circular(AppRadii.full),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: colors.brandEmeraldDark,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'orders.timeline_active_stage'.tr(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: colors.brandEmeraldDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isCancelled
                          ? colors.medicalRed.withValues(alpha: 0.8)
                          : colors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, Color) _resolveColors(AppColorsExtension colors) {
    if (isCancelled) {
      return (colors.medicalRed, colors.onPrimary, colors.borderSubtle);
    }
    if (isCompleted) {
      return (
        colors.brandEmeraldDark,
        colors.onPrimary,
        colors.brandEmeraldDark
      );
    }
    if (isActive) {
      return (
        colors.primary,
        colors.onPrimary,
        colors.surfaceContainerHigh
      );
    }
    return (
      colors.surfaceContainerHigh,
      colors.onSurfaceVariant,
      colors.surfaceContainerHigh
    );
  }
}
