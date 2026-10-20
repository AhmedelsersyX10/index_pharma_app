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
    final currency = 'cart.currency'.tr();
    final formattedAmount = subtotal.toStringAsFixed(2);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.canvasPure,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        boxShadow: AppShadows.level1,
        border: Border.all(color: AppColors.borderSubtle),
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
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spaceSm),
                  Text(
                    'checkout.summary_title'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
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
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
                child: Text(
                  'checkout.items_count'.tr(args: [totalItemsCount.toString()]),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
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
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.secondaryMuted,
                ),
              ),
              Text(
                '$formattedAmount $currency',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          const Divider(color: AppColors.surfaceContainer, height: 1),
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'checkout.tax_note'.tr(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.secondaryMuted,
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
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    currency,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceMd),
          Container(
            padding: const EdgeInsets.all(AppSpacing.spaceSm),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_user_rounded,
                  color: AppColors.brandEmeraldDark,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.spaceSm),
                Expanded(
                  child: Text(
                    'checkout.eda_guarantee'.tr(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurface,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
