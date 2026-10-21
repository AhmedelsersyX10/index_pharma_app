import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Prescription Reminder Card (Stitch C1).
///
/// Displayed whenever the cart contains at least one item requiring a prescription (Rx).
class CartRxReminderCard extends StatelessWidget {
  const CartRxReminderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceMd,
        vertical: AppSpacing.spaceSm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: AppRadii.roundedXl,
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_outlined, size: 20, color: AppColors.primary),
          const SizedBox(width: AppSpacing.spaceSm),
          Expanded(
            child: Text(
              AppLocaleKeys.cartRxNoticeText.tr(),
              style: AppTypography.bodySm(
                color: AppColors.onSecondaryContainer,
              ).copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spaceSm,
              vertical: AppSpacing.space2xs,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: AppRadii.roundedFull,
            ),
            child: Text(
              AppLocaleKeys.cartRxNoticeBadge.tr(),
              style: AppTypography.labelSm(
                color: AppColors.brandEmeraldDark,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
