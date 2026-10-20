import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/features/choose_branches/domain/entities/branch_entity.dart';
import 'package:index_pharma/features/choose_branches/presentation/cubit/branch_cubit.dart';
import 'package:index_pharma/features/choose_branches/presentation/cubit/branch_state.dart';

/// Branch selector strip shown below the header per Stitch B2 design.
///
/// Features:
/// - Pill button displaying currently selected branch with store icon and expand arrow.
/// - Live stock indicator pill badge.
class HomeBranchSelectorStrip extends StatelessWidget {
  const HomeBranchSelectorStrip({
    super.key,
    this.onTapBranch,
  });

  final VoidCallback? onTapBranch;

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

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Branch Pill
            Flexible(
              child: Material(
                color: AppColors.surfaceContainer,
                borderRadius: AppRadii.roundedFull,
                child: InkWell(
                  onTap: onTapBranch ??
                      () => context.push(AppRouter.kBranchSelectionView),
                  borderRadius: AppRadii.roundedFull,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.spaceSm,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.storefront_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.spaceXs),
                        Flexible(
                          child: Text(
                            branchName,
                            style: AppTypography.labelMd(
                              color: AppColors.onSurface,
                            ).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.space2xs),
                        const Icon(
                          Icons.expand_more_rounded,
                          size: 16,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.spaceSm),

            // Live Stock Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: AppRadii.roundedFull,
                boxShadow: AppShadows.level1,
                border: Border.all(
                  color: AppColors.brandMintBorder,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space2xs),
                  Text(
                    AppLocaleKeys.homeLiveStock.tr(),
                    style: AppTypography.labelSm(
                      color: AppColors.primary,
                    ).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
