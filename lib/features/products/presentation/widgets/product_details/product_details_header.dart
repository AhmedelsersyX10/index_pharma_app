import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';

/// Clinical app bar for the Product Details screen per Stitch B4.
class ProductDetailsHeader extends StatelessWidget implements PreferredSizeWidget {
  const ProductDetailsHeader({
    super.key,
    this.onBack,
    this.onCartTap,
  });

  final VoidCallback? onBack;
  final VoidCallback? onCartTap;

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return AppBar(
      backgroundColor: AppColors.background.withValues(alpha: 0.95),
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      leading: IconButton(
        icon: Icon(
          isRtl ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
          color: AppColors.onSurface,
          size: 24,
        ),
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: onBack ?? () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppRouter.kStoreView);
          }
        },
      ),
      title: Text(
        AppLocaleKeys.productDetailsTitle.tr(),
        style: AppTypography.titleLg(color: AppColors.onSurface).copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.shopping_bag_outlined,
            color: AppColors.onSurface,
            size: 22,
          ),
          tooltip: AppLocaleKeys.placeholdersCartTitle.tr(),
          onPressed: onCartTap ?? () => context.push(AppRouter.kCartView),
        ),
        const SizedBox(width: AppSpacing.spaceXs),
      ],
    );
  }
}
