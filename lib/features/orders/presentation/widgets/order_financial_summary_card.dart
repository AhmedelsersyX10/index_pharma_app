import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/widgets/app_badges.dart';

/// Financial summary breakdown card (Stitch C5).
/// Strict alignment with backend: subtotal and total amount; cash on delivery only.
class OrderFinancialSummaryCard extends StatelessWidget {
  const OrderFinancialSummaryCard({
    super.key,
    required this.subtotal,
    required this.totalAmount,
    this.paymentMethod = 'cash',
  });

  final double subtotal;
  final double totalAmount;
  final String paymentMethod;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: colors.canvasPure,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: colors.borderSubtle),
        boxShadow: context.shadowsLevel1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Icon(
                Icons.receipt_long_rounded,
                size: 20,
                color: colors.primary,
              ),
              const SizedBox(width: AppSpacing.spaceXs),
              Text(
                'orders.financial_summary_title'.tr(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceMd),

          // Subtotal Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'orders.subtotal_label'.tr(),
                style: TextStyle(
                  fontSize: 13,
                  color: colors.onSurfaceVariant,
                ),
              ),
              Text(
                '${subtotal.toStringAsFixed(2)} ${'orders.currency'.tr()}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceSm),

          // Total Highlight Strip
          Container(
            padding: const EdgeInsets.all(AppSpacing.spaceSm),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'orders.total_amount_label'.tr(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'orders.tax_included_label'.tr(),
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${totalAmount.toStringAsFixed(2)} ${'orders.currency'.tr()}',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.spaceMd),

          // Payment Method Strip
          Container(
            padding: const EdgeInsets.all(AppSpacing.spaceSm),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: colors.borderSubtle),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colors.brandMintSurface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.payments_rounded,
                        size: 16,
                        color: colors.brandEmeraldDark,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spaceSm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'orders.payment_method_label'.tr(),
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'orders.payment_cod'.tr(),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                AppBadge.trust(
                  label: 'orders.cod_badge'.tr(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
