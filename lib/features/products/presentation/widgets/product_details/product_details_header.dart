import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/core/widgets/app_page_bar.dart';
import 'package:index_pharma/core/widgets/cart_action_button.dart';

/// Clinical app bar for the Product Details screen built on unified [AppPageBar].
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
      title: AppLocaleKeys.productDetailsTitle.tr(),
      actions: [
        CartActionButton(
          onTap: onCartTap ?? () => context.push(AppRouter.kCartView),
        ),
        const SizedBox(width: AppSpacing.spaceXs),
      ],
    );
  }
}
