import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:index_pharma/core/theme/theme.dart';
import '../../domain/entities/customer_order.dart';
import '../../domain/entities/order_status.dart';
import '../widgets/order_delivery_info_card.dart';
import '../widgets/order_financial_summary_card.dart';
import '../widgets/order_items_section.dart';
import '../widgets/order_status_badge.dart';
import '../widgets/order_timeline_view.dart';

/// Customer Order Details screen (Stitch C5).
/// Displays real order tracking progression, ordered items, delivery info, and financial breakdown.
class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  final CustomerOrder order;

  @override
  Widget build(BuildContext context) {
    final dateFormat =
        DateFormat('d MMMM yyyy, hh:mm a', context.locale.languageCode);
    final formattedDate = dateFormat.format(order.createdAt);
    final isCancelled = order.statusEnum == OrderStatus.cancelled;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.canvasPure,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          'orders.details_title'.tr(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cancellation Alert Banner (if cancelled)
            if (isCancelled) ...[
              _buildCancellationBanner(context),
              const SizedBox(height: AppSpacing.spaceMd),
            ],

            // Section 1: Order Header & Core Metadata Card
            _buildOrderHeaderCard(context, formattedDate),
            const SizedBox(height: AppSpacing.spaceMd),

            // Section 2: Real Order Timeline
            Container(
              padding: const EdgeInsets.all(AppSpacing.spaceMd),
              decoration: BoxDecoration(
                color: AppColors.canvasPure,
                borderRadius: BorderRadius.circular(AppRadii.xl),
                border: Border.all(color: AppColors.borderSubtle),
                boxShadow: AppShadows.level1,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.timeline_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.spaceXs),
                      Text(
                        'orders.timeline_title'.tr(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.spaceLg),
                  OrderTimelineView(status: order.statusEnum),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.spaceMd),

            // Section 3: Ordered Medicines
            OrderItemsSection(items: order.items),
            const SizedBox(height: AppSpacing.spaceMd),

            // Section 4: Delivery & Contact Details
            OrderDeliveryInfoCard(
              deliveryAddress: order.deliveryAddress,
              customerPhone: order.customerPhone,
              notes: order.notes,
            ),
            const SizedBox(height: AppSpacing.spaceMd),

            // Section 5: Financial Breakdown
            OrderFinancialSummaryCard(
              subtotal: order.subtotal,
              totalAmount: order.totalAmount,
              paymentMethod: order.paymentMethod,
            ),
            const SizedBox(height: AppSpacing.spaceXl),
          ],
        ),
      ),
    );
  }

  Widget _buildCancellationBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.badgeErrorBg,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: AppColors.badgeErrorText.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.medicalRed,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cancel_rounded,
              color: AppColors.onPrimary,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'orders.timeline_cancelled_title'.tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.badgeErrorText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'orders.timeline_cancelled_desc'.tr(),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.badgeErrorText.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHeaderCard(BuildContext context, String formattedDate) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.canvasPure,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Order Number Bar
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.spaceSm,
                      vertical: AppSpacing.spaceXs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          order.orderNumber,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () => _copyOrderNumber(context),
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                          child: const Padding(
                            padding: EdgeInsets.all(2.0),
                            child: Icon(
                              Icons.copy_rounded,
                              size: 15,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Dynamic Status Badge
              OrderStatusBadge(status: order.statusEnum),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceSm),

          // Date & Time
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: AppColors.secondaryMuted,
              ),
              const SizedBox(width: AppSpacing.spaceXs),
              Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _copyOrderNumber(BuildContext context) {
    Clipboard.setData(ClipboardData(text: order.orderNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('orders.copied_feedback'.tr()),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
