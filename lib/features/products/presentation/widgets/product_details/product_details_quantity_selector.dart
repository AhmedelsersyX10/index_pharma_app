import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/widgets/app_card.dart';

/// Accessible Medical Stepper & Quantity Selector per Stitch B4.
class ProductDetailsQuantitySelector extends StatelessWidget {
  const ProductDetailsQuantitySelector({
    super.key,
    required this.quantity,
    required this.maxStock,
    required this.unit,
    required this.onChanged,
  });

  final int quantity;
  final int maxStock;
  final String unit;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final effectiveMax = maxStock > 0 ? maxStock : 1;
    final canDecrement = quantity > 1 && maxStock > 0;
    final canIncrement = quantity < effectiveMax && maxStock > 0;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocaleKeys.productDetailsRequestedQuantity.tr(),
                  style: AppTypography.titleMd(
                    color: AppColors.onSurface,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.space2xs),
                Text(
                  maxStock > 0
                      ? AppLocaleKeys.productDetailsMaxAvailableStock.tr(
                          args: [maxStock.toString(), unit],
                        )
                      : AppLocaleKeys.productDetailsOutOfStock.tr(),
                  style: AppTypography.bodySm(
                    color: maxStock > 0 ? AppColors.slate500 : AppColors.medicalRed,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.spaceSm),

          // Stepper
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: AppRadii.roundedMd,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Decrement Button
                _StepperButton(
                  icon: Icons.remove_rounded,
                  isEnabled: canDecrement,
                  onTap: () {
                    if (canDecrement) {
                      onChanged(quantity - 1);
                    }
                  },
                ),
                SizedBox(
                  width: 44,
                  child: Text(
                    maxStock > 0 ? quantity.toString() : '0',
                    textAlign: TextAlign.center,
                    style: AppTypography.headlineMd(
                      color: AppColors.onSurface,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                // Increment Button
                _StepperButton(
                  icon: Icons.add_rounded,
                  isEnabled: canIncrement,
                  isPrimary: true,
                  onTap: () {
                    if (canIncrement) {
                      onChanged(quantity + 1);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.isEnabled,
    this.isPrimary = false,
    required this.onTap,
  });

  final IconData icon;
  final bool isEnabled;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: AppRadii.roundedSm,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.surfaceContainerLowest : AppColors.surfaceContainerLow,
          borderRadius: AppRadii.roundedSm,
        ),
        child: Icon(
          icon,
          size: 18,
          color: isEnabled
              ? (isPrimary ? AppColors.primary : AppColors.onSurface)
              : AppColors.slate300,
        ),
      ),
    );
  }
}
