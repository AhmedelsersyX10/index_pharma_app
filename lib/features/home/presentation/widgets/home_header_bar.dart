import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/core/widgets/cart_action_button.dart';

/// Top App Bar / Header for B2 Customer Home screen.
///
/// Features:
/// - Clinical brand icon ("IP")
/// - Title ("الرئيسية" / "Home") and active branch label
/// - Cart icon with item count badge
/// - Account profile icon
class HomeHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeHeaderBar({
    super.key,
    this.cartItemCount = 0,
    this.onBranchTap,
    this.onCartTap,
    this.onAccountTap,
  });

  final int cartItemCount;
  final VoidCallback? onBranchTap;
  final VoidCallback? onCartTap;
  final VoidCallback? onAccountTap;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: preferredSize.height + MediaQuery.paddingOf(context).top,
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top,
        left: AppSpacing.marginMobile,
        right: AppSpacing.marginMobile,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(
            color: colors.borderSubtle,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Brand Logo & Branch Info
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: AppRadii.roundedLg,
                ),
                alignment: Alignment.center,
                child: const Text(
                  'IP',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.spaceSm),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    AppLocaleKeys.homeTitle.tr(),
                    style: AppTypography.titleMd(
                      color: colors.onSurface,
                    ).copyWith(fontWeight: FontWeight.bold, fontSize: 18, height: 1.1),
                  ),
                ],
              ),
            ],
          ),

          // Actions: Cart and Account
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cart Button with Badge
              CartActionButton(onTap: onCartTap ?? () => context.push(AppRouter.kCartView)),
              const SizedBox(width: AppSpacing.space2xs),

              // Account Button
              InkWell(
                onTap: onAccountTap ?? () => context.go('/account'),
                borderRadius: AppRadii.roundedFull,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: const Icon(Icons.person_rounded, size: 20, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
