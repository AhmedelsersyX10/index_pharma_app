import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';

/// Clinical empty cart view (Stitch C1).
class CartEmptyView extends StatelessWidget {
  const CartEmptyView({
    super.key,
    this.onBrowseTap,
  });

  final VoidCallback? onBrowseTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceXl,
          vertical: AppSpacing.space2xl,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular clinical illustration
            Container(
              width: 130,
              height: 130,
              decoration: const BoxDecoration(
                color: AppColors.brandMintSurface,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.level2,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.remove_shopping_cart_outlined,
                  size: 44,
                  color: AppColors.brandEmeraldDark,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.spaceLg),

            // Title
            Text(
              AppLocaleKeys.cartEmptyTitle.tr(),
              style: AppTypography.headlineMd(
                color: AppColors.onSurface,
              ).copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.spaceSm),

            // Description
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                AppLocaleKeys.cartEmptyDesc.tr(),
                style: AppTypography.bodyMd(color: AppColors.secondary),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: AppSpacing.spaceXl),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onBrowseTap ??
                    () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(AppRouter.kStoreView);
                      }
                    },
                icon: const Icon(Icons.search_rounded, size: 20),
                label: Text(
                  AppLocaleKeys.cartBrowseBtn.tr(),
                  style: AppTypography.labelLg(
                    color: Colors.white,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadii.roundedLg,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
