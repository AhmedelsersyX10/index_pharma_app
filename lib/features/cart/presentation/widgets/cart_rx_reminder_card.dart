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
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceMd,
        vertical: AppSpacing.spaceSm,
      ),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: AppRadii.roundedXl,
      ),
      child: Row(
        children: [
          Icon(Icons.receipt_long_outlined, size: 20, color: colors.primary),
          const SizedBox(width: AppSpacing.spaceSm),
          Expanded(
            child: Text(
              AppLocaleKeys.cartRxNoticeText.tr(),
              style: AppTypography.bodySm(
                color: colors.onSecondaryContainer,
              ).copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spaceSm,
              vertical: AppSpacing.space2xs,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: AppRadii.roundedFull,
            ),
            child: Text(
              AppLocaleKeys.cartRxNoticeBadge.tr(),
              style: AppTypography.labelSm(
                color: colors.brandEmeraldDark,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
