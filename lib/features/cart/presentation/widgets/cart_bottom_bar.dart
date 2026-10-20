import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Sticky bottom checkout action bar for C1 Cart screen.
class CartBottomBar extends StatelessWidget {
  const CartBottomBar({
    super.key,
    required this.totalAmount,
    required this.onCheckout,
    this.isLoading = false,
  });

  final double totalAmount;
  final VoidCallback onCheckout;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.marginMobile,
        right: AppSpacing.marginMobile,
        top: AppSpacing.spaceSm,
        bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.spaceSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        boxShadow: AppShadows.level3,
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Total Amount display
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocaleKeys.cartStickyTotalLabel.tr(),
                style: AppTypography.labelSm(color: AppColors.secondary),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    totalAmount.toStringAsFixed(2),
                    style: AppTypography.titleLg(
                      color: AppColors.primary,
                    ).copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: AppSpacing.space2xs),
                  Text(
                    AppLocaleKeys.cartCurrency.tr(),
                    style: AppTypography.labelSm(
                      color: AppColors.primary,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(width: AppSpacing.spaceMd),

          // Primary Checkout CTA
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : onCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadii.roundedLg,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spaceMd,
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocaleKeys.cartCheckoutBtn.tr(),
                            style: AppTypography.labelLg(
                              color: Colors.white,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: AppSpacing.spaceXs),
                          Icon(
                            isRtl
                                ? Icons.arrow_back_rounded
                                : Icons.arrow_forward_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
