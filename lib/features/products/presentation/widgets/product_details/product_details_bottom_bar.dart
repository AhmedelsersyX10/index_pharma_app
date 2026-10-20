import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Sticky Bottom Cart Action Bar per Stitch B4.
class ProductDetailsBottomBar extends StatelessWidget {
  const ProductDetailsBottomBar({
    super.key,
    required this.unitPrice,
    required this.quantity,
    required this.isAvailable,
    required this.onAddToCart,
  });

  final double unitPrice;
  final int quantity;
  final bool isAvailable;
  final VoidCallback onAddToCart;

  String _formatTotal() {
    final total = quantity * unitPrice;
    return total.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.08),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.marginMobile,
        right: AppSpacing.marginMobile,
        top: AppSpacing.spaceSm,
        bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.spaceSm,
      ),
      child: Row(
        children: [
          // Total Price Display
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocaleKeys.productDetailsTotalPriceLabel.tr(),
                style: AppTypography.labelSm(
                  color: AppColors.slate500,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _formatTotal(),
                    style: AppTypography.headlineMd(
                      color: AppColors.primary,
                    ).copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: AppSpacing.space2xs),
                  Text(
                    AppLocaleKeys.productsCurrency.tr(),
                    style: AppTypography.labelSm(
                      color: AppColors.onSurface,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.spaceMd),

          // Add to Cart Button
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: isAvailable ? onAddToCart : null,
                icon: const Icon(
                  Icons.add_shopping_cart_rounded,
                  size: 20,
                  color: Colors.white,
                ),
                label: Text(
                  isAvailable
                      ? AppLocaleKeys.productDetailsAddToCartCta.tr()
                      : AppLocaleKeys.productDetailsOutOfStock.tr(),
                  style: AppTypography.labelLg(color: Colors.white).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.slate300,
                  disabledForegroundColor: AppColors.slate500,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadii.roundedLg,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceSm),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
