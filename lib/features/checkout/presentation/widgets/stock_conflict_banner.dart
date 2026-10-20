import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Clinical warning banner shown when an HTTP 409 stock conflict or
/// product unavailability occurs during checkout.
class StockConflictBanner extends StatelessWidget {
  const StockConflictBanner({
    super.key,
    required this.message,
    required this.onReturnToCart,
  });

  final String message;
  final VoidCallback onReturnToCart;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.spaceMd),
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        boxShadow: AppShadows.level1,
        border: Border.all(
          color: AppColors.medicalRed.withAlpha(51),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: AppColors.onError,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'checkout.stock_conflict_title'.tr(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.onErrorContainer,
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceSm),
                ElevatedButton.icon(
                  onPressed: onReturnToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.onError,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.spaceMd,
                      vertical: AppSpacing.spaceSm,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                  ),
                  icon: const Icon(Icons.shopping_cart_checkout_rounded, size: 18),
                  label: Text(
                    'checkout.return_to_cart_btn'.tr(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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
