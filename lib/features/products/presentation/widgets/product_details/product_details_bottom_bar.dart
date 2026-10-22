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
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: colors.onSurface.withValues(alpha: 0.08),
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
                  color: colors.neutral,
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
                      color: colors.primary,
                    ).copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: AppSpacing.space2xs),
                  Text(
                    AppLocaleKeys.productsCurrency.tr(),
                    style: AppTypography.labelSm(
                      color: colors.onSurface,
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
                icon: Icon(
                  Icons.add_shopping_cart_rounded,
                  size: 20,
                  color: colors.onPrimary,
                ),
                label: Text(
                  isAvailable
                      ? AppLocaleKeys.productDetailsAddToCartCta.tr()
                      : AppLocaleKeys.productDetailsOutOfStock.tr(),
                  style: AppTypography.labelLg(color: colors.onPrimary).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  disabledBackgroundColor: colors.surfaceContainerHigh,
                  disabledForegroundColor: colors.neutral,
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
