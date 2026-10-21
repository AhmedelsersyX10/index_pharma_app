import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Stock adjustment alert banner (Stitch C1).
///
/// Displayed when a user requests a quantity exceeding current branch inventory,
/// and the quantity has been clamped to the maximum available stock.
class CartStockAlertBanner extends StatelessWidget {
  const CartStockAlertBanner({super.key, required this.productName, required this.onDismiss});

  final String productName;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: const BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: AppRadii.roundedXl,
        boxShadow: AppShadows.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.medicalRed, size: 24),
              const SizedBox(width: AppSpacing.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocaleKeys.cartStockAlertTitle.tr(),
                      style: AppTypography.titleMd(
                        color: AppColors.onErrorContainer,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.space2xs),
                    Text(
                      AppLocaleKeys.cartStockAlertDesc.tr(args: [productName]),
                      style: AppTypography.bodySm(color: AppColors.onErrorContainer),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: onDismiss,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.surfaceContainerLowest,
                foregroundColor: AppColors.onErrorContainer,
                shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedFull),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spaceMd,
                  vertical: AppSpacing.space2xs,
                ),
              ),
              child: Text(
                AppLocaleKeys.cartStockAlertDismiss.tr(),
                style: AppTypography.labelSm(
                  color: AppColors.onErrorContainer,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
