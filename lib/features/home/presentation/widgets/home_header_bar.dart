import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:index_pharma/features/cart/presentation/cubit/cart_state.dart';
import 'package:index_pharma/features/choose_branches/domain/entities/branch_entity.dart';
import 'package:index_pharma/features/choose_branches/presentation/cubit/branch_cubit.dart';
import 'package:index_pharma/features/choose_branches/presentation/cubit/branch_state.dart';

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
    return Container(
      height: preferredSize.height + MediaQuery.paddingOf(context).top,
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top,
        left: AppSpacing.marginMobile,
        right: AppSpacing.marginMobile,
      ),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.95),
        boxShadow: AppShadows.level1,
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
                decoration: const BoxDecoration(
                  color: AppColors.primary,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocaleKeys.homeTitle.tr(),
                    style: AppTypography.titleMd(color: AppColors.onSurface)
                        .copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  _ActiveBranchSubtitle(onTap: onBranchTap),
                ],
              ),
            ],
          ),

          // Actions: Cart and Account
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cart Button with Badge
              Builder(
                builder: (context) {
                  int effectiveCount = cartItemCount;
                  try {
                    final cartState = context.watch<CartCubit>().state;
                    if (cartState is CartHasItems) {
                      effectiveCount = cartState.totalItemsCount;
                    } else if (cartState is CartEmpty) {
                      effectiveCount = 0;
                    }
                  } catch (_) {
                    // When CartCubit is not in the widget tree (e.g. isolated test)
                  }

                  return IconButton(
                    tooltip: AppLocaleKeys.cartTitle.tr(),
                    onPressed: onCartTap ?? () => context.push(AppRouter.kCartView),
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.shopping_bag_outlined,
                          size: 24,
                          color: AppColors.onSurfaceVariant,
                        ),
                        if (effectiveCount > 0)
                          PositionedDirectional(
                            top: -4,
                            end: -4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              decoration: const BoxDecoration(
                                color: AppColors.medicalRed,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                effectiveCount > 99 ? '99+' : '$effectiveCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: AppSpacing.space2xs),

              // Account Button
              InkWell(
                onTap: onAccountTap ?? () => context.go('/account'),
                borderRadius: AppRadii.roundedFull,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.person_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActiveBranchSubtitle extends StatelessWidget {
  const _ActiveBranchSubtitle({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BranchCubit, BranchState>(
      builder: (context, state) {
        String branchName = AppLocaleKeys.homeSelectBranch.tr();

        if (state is BranchLoaded && state.selectedBranchId != null) {
          final BranchEntity? branch = state.branches
              .where((b) => b.id == state.selectedBranchId)
              .firstOrNull;
          if (branch != null) {
            branchName = branch.name;
          }
        }

        return InkWell(
          onTap: onTap ??
              () => context.push(AppRouter.kBranchSelectionView),
          borderRadius: AppRadii.roundedSm,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: 2),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Text(
                  branchName,
                  style: AppTypography.labelSm(
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ],
          ),
        );
      },
    );
  }
}
