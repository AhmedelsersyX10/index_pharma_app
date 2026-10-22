import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/core/widgets/app_page_bar.dart';

/// Top App Bar for the C1 Cart screen built on unified [AppPageBar].
///
/// Features:
/// - Direction-aware back navigation button.
/// - Screen title ("سلة المشتريات").
/// - Active branch context badge.
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
    final colors = context.colors;

    return AppPageBar(
      height: preferredSize.height,
      centerTitle: true,
      onBackPressed: onBack ??
          () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRouter.kStoreView);
            }
          },
      title: AppLocaleKeys.cartTitle.tr(),
      actions: [
        if (branchName != null && branchName!.trim().isNotEmpty) ...[
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spaceSm,
                vertical: AppSpacing.space2xs,
              ),
              decoration: BoxDecoration(
                color: colors.brandMintSurface,
                borderRadius: AppRadii.roundedFull,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.storefront_outlined,
                    size: 16,
                    color: colors.brandEmeraldDark,
                  ),
                  const SizedBox(width: AppSpacing.space2xs),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 140),
                    child: Text(
                      branchName!,
                      style: AppTypography.labelSm(
                        color: colors.brandEmeraldDark,
                      ).copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.spaceSm),
        ],
      ],
    );
  }
}
