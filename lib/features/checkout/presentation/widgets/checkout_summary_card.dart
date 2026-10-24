import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Card summarizing items count, subtotal, and total due amount.
/// Note: No delivery fee is displayed per backend API contract (totalAmount == subtotal).
class CheckoutSummaryCard extends StatelessWidget {
  const CheckoutSummaryCard({
    super.key,
    required this.totalItemsCount,
    required this.subtotal,
  });

  final int totalItemsCount;
  final double subtotal;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currency = 'cart.currency'.tr();
    final formattedAmount = subtotal.toStringAsFixed(2);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: colors.canvasPure,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        boxShadow: context.shadowsLevel1,
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: colors.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.receipt_rounded,
                      color: colors.primary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spaceSm),
                  Text(
                    'checkout.summary_title'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spaceSm,
                  vertical: AppSpacing.space2xs,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
                child: Text(
                  'checkout.items_count'.tr(args: [totalItemsCount.toString()]),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'checkout.subtotal_label'.tr(),
                style: TextStyle(fontSize: 14, color: colors.secondaryMuted),
              ),
              Text(
                '$formattedAmount $currency',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          Divider(color: colors.surfaceContainer, height: 1),
          const SizedBox(height: AppSpacing.spaceSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'checkout.total_due_label'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'checkout.tax_note'.tr(),
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.secondaryMuted,
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    formattedAmount,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    currency,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
