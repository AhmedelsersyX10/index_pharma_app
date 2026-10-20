import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';

/// Top App Bar for the C1 Cart screen adhering strictly to Stitch clinical design.
///
/// Features:
/// - Direction-aware back navigation button.
/// - Screen title ("سلة المشتريات").
/// - Active branch context badge.
/// - Item count indicator.
class CartHeader extends StatelessWidget implements PreferredSizeWidget {
  const CartHeader({
    super.key,
    this.branchName,
    this.itemsCount = 0,
    this.onBack,
  });

  final String? branchName;
  final int itemsCount;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return AppBar(
      backgroundColor: AppColors.surface.withValues(alpha: 0.95),
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
        onPressed: onBack ??
            () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRouter.kStoreView);
              }
            },
      ),
      title: Text(
        AppLocaleKeys.cartTitle.tr(),
        style: AppTypography.titleLg(color: AppColors.onSurface).copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        if (branchName != null && branchName!.trim().isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spaceSm,
              vertical: AppSpacing.space2xs,
            ),
            decoration: const BoxDecoration(
              color: AppColors.brandMintSurface,
              borderRadius: AppRadii.roundedFull,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.storefront_outlined,
                  size: 16,
                  color: AppColors.brandEmeraldDark,
                ),
                const SizedBox(width: AppSpacing.space2xs),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 140),
                  child: Text(
                    branchName!,
                    style: AppTypography.labelSm(
                      color: AppColors.brandEmeraldDark,
                    ).copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.spaceSm),
        ],
      ],
    );
  }
}
