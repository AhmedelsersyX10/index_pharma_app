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
    final colors = context.colors;

    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadii.roundedXl,
      ),
      backgroundColor: colors.surfaceContainerLowest,
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: colors.medicalAmber,
            size: 26,
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          Expanded(
            child: Text(
              AppLocaleKeys.cartBranchConflictTitle.tr(),
              style: AppTypography.titleMd(
                color: colors.onSurface,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Text(
        AppLocaleKeys.cartBranchConflictMessage.tr(),
        style: AppTypography.bodyMd(color: colors.onSurfaceVariant),
      ),
      actionsPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceMd,
        vertical: AppSpacing.spaceSm,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: colors.secondary,
          ),
          child: Text(
            AppLocaleKeys.cartBranchConflictCancel.tr(),
            style: AppTypography.labelMd(color: colors.secondary),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.medicalRed,
            foregroundColor: colors.onPrimary,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadii.roundedMd,
            ),
          ),
          child: Text(
            AppLocaleKeys.cartBranchConflictConfirm.tr(),
            style: AppTypography.labelMd(
              color: colors.onPrimary,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
