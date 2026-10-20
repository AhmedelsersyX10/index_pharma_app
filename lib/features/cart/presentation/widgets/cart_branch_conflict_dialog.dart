import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Confirmation dialog shown before clearing the customer's cart when switching branches.
class CartBranchConflictDialog extends StatelessWidget {
  const CartBranchConflictDialog({super.key});

  /// Displays the dialog and returns `true` if the user confirms clearing the cart.
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const CartBranchConflictDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadii.roundedXl,
      ),
      backgroundColor: AppColors.surfaceContainerLowest,
      title: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.medicalAmber,
            size: 26,
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          Expanded(
            child: Text(
              AppLocaleKeys.cartBranchConflictTitle.tr(),
              style: AppTypography.titleMd(
                color: AppColors.onSurface,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Text(
        AppLocaleKeys.cartBranchConflictMessage.tr(),
        style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant),
      ),
      actionsPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceMd,
        vertical: AppSpacing.spaceSm,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.secondary,
          ),
          child: Text(
            AppLocaleKeys.cartBranchConflictCancel.tr(),
            style: AppTypography.labelMd(color: AppColors.secondary),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.medicalRed,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadii.roundedMd,
            ),
          ),
          child: Text(
            AppLocaleKeys.cartBranchConflictConfirm.tr(),
            style: AppTypography.labelMd(
              color: Colors.white,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
