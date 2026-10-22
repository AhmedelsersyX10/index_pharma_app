import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:index_pharma/features/products/domain/entities/product.dart';

/// Presentation helper orchestrating add-to-cart operations, feedback SnackBar
/// displays, and the branch-conflict resolution dialog.
///
/// Ensures consistent user experience across Home, Product Details, and catalog widgets.
abstract final class CartActionHelper {
  /// Adds [product] to cart via [cartCubit] and displays appropriate feedback.
  ///
  /// - [AddToCartStatus.outOfStock]: localized out-of-stock warning SnackBar.
  /// - [AddToCartStatus.branchConflict]: dialog prompting to cancel or clear cart & add this product.
  /// - [AddToCartStatus.success]:
  ///   - if [wasCapped]: localized message warning that quantity was capped to available stock.
  ///   - otherwise: localized success SnackBar with "View Cart" action.
  ///
  /// Returns the final [AddToCartResult], or null if context was unmounted.
  static Future<AddToCartResult?> addProductToCart({
    required BuildContext context,
    required CartCubit cartCubit,
    required Product product,
    int quantity = 1,
    VoidCallback? onViewCart,
  }) async {
    final result = await cartCubit.addToCart(product, quantity: quantity);
    if (!context.mounted) return result;

    switch (result.status) {
      case AddToCartStatus.outOfStock:
        _showOutOfStockSnackBar(context);
        return result;

      case AddToCartStatus.branchConflict:
        final confirmed = await _showBranchConflictDialog(context);
        if (!context.mounted) return result;

        if (confirmed) {
          final replaceResult = await cartCubit.clearAndAddToCart(
            product,
            quantity: quantity,
          );
          if (!context.mounted) return replaceResult;

          if (replaceResult.isSuccess) {
            if (replaceResult.wasCapped) {
              _showCappedSnackBar(context, product, onViewCart);
            } else {
              _showSuccessSnackBar(context, product, onViewCart);
            }
          }
          return replaceResult;
        }
        return result;

      case AddToCartStatus.success:
        if (result.wasCapped) {
          _showCappedSnackBar(context, product, onViewCart);
        } else {
          _showSuccessSnackBar(context, product, onViewCart);
        }
        return result;
    }
  }

  static Future<bool> _showBranchConflictDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedXl),
          title: Text(
            AppLocaleKeys.cartBranchConflictTitle.tr(),
            style: AppTypography.titleMd(color: AppColors.onSurface).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            AppLocaleKeys.cartBranchConflictMessage.tr(),
            style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                AppLocaleKeys.cartBranchConflictCancel.tr(),
                style: AppTypography.labelLg(color: AppColors.slate600),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadii.roundedMd,
                ),
              ),
              child: Text(
                AppLocaleKeys.cartBranchConflictConfirm.tr(),
                style: AppTypography.labelLg(color: Colors.white).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  static void _showSuccessSnackBar(
    BuildContext context,
    Product product,
    VoidCallback? onViewCart,
  ) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.primaryFixed,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.spaceSm),
            Expanded(
              child: Text(
                AppLocaleKeys.cartItemAddedSuccess.tr(args: [product.name]),
                style: AppTypography.bodyMd(color: AppColors.inverseOnSurface),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: AppLocaleKeys.cartViewCartAction.tr(),
          textColor: AppColors.primaryFixed,
          onPressed: onViewCart ?? () => context.push(AppRouter.kCartView),
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.inverseSurface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
      ),
    );
  }

  static void _showCappedSnackBar(
    BuildContext context,
    Product product,
    VoidCallback? onViewCart,
  ) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: AppColors.medicalAmber,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.spaceSm),
            Expanded(
              child: Text(
                AppLocaleKeys.cartStockAlertDesc.tr(args: [product.name]),
                style: AppTypography.bodyMd(color: AppColors.inverseOnSurface),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: AppLocaleKeys.cartViewCartAction.tr(),
          textColor: AppColors.primaryFixed,
          onPressed: onViewCart ?? () => context.push(AppRouter.kCartView),
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.inverseSurface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
      ),
    );
  }

  static void _showOutOfStockSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.medicalAmber,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.spaceSm),
            Expanded(
              child: Text(
                AppLocaleKeys.productDetailsOutOfStock.tr(),
                style: AppTypography.bodyMd(color: AppColors.inverseOnSurface),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.inverseSurface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
      ),
    );
  }
}
