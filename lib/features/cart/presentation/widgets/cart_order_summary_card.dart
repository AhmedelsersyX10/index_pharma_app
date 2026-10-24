import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Order Summary Card for C1 Cart screen.
///
/// Features:
/// - Title with receipt icon.
/// - Subtotal row showing total unit count and price.
/// - Estimated total amount (strictly computed from selling prices, with no unverified fees).
/// - Official Egyptian Drug Authority (EDA) pricing compliance notice.
class CartOrderSummaryCard extends StatelessWidget {
  const CartOrderSummaryCard({
    super.key,
    required this.subtotal,
    required this.totalUnitsCount,
  });

  final double subtotal;
  final int totalUnitsCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: AppRadii.roundedXl,
        boxShadow: context.shadowsLevel1,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocaleKeys.cartSummaryTitle.tr(),
                style: AppTypography.titleMd(
                  color: colors.onSurface,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              Icon(
                Icons.receipt_long_outlined,
                size: 20,
                color: colors.secondary,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.spaceSm),

          // Subtotal Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocaleKeys.cartSubtotalLabel.tr(
                  args: [
                    AppLocaleKeys.cartItemsCount.tr(
                      args: [totalUnitsCount.toString()],
                    ),
                  ],
                ),
                style: AppTypography.bodyMd(color: colors.onSurfaceVariant),
              ),
              Text(
                '${subtotal.toStringAsFixed(2)} ${AppLocaleKeys.cartCurrency.tr()}',
                style: AppTypography.bodyMd(
                  color: colors.onSurface,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceSm),
            child: Divider(
              color: colors.surfaceContainerLow,
              height: 1,
              thickness: 1,
            ),
          ),

          // Estimated Total Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocaleKeys.cartTotalLabel.tr(),
                    style: AppTypography.titleMd(
                      color: colors.onSurface,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppLocaleKeys.cartTotalNote.tr(),
                    style: AppTypography.labelSm(color: colors.secondary),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    subtotal.toStringAsFixed(2),
                    style: AppTypography.headlineLg(
                      color: colors.primary,
                    ).copyWith(fontWeight: FontWeight.w800, fontSize: 22),
                  ),
                  const SizedBox(width: AppSpacing.space2xs),
                  Text(
                    AppLocaleKeys.cartCurrency.tr(),
                    style: AppTypography.labelMd(
                      color: colors.primary,
                    ).copyWith(fontWeight: FontWeight.bold),
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
