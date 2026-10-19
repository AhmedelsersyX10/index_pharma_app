import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Introductory header section displaying geographic coverage, branch count,
/// and contextual purpose of branch selection.
class BranchIntroSection extends StatelessWidget {
  const BranchIntroSection({
    super.key,
    required this.branchesCount,
    this.onAutoLocatePressed,
  });

  final int branchesCount;
  final VoidCallback? onAutoLocatePressed;

  @override
  Widget build(BuildContext context) {
    final countText = branchesCount == 1
        ? 'branch_selection.single_active_branch'.tr()
        : 'branch_selection.active_branches_count'.tr(args: [branchesCount.toString()]);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top pills row (Region coverage & auto locate button)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Region badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spaceMd,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.space2xs),
                    Text(
                      'branch_selection.region_title'.tr(),
                      style: AppTypography.labelMd(
                        color: AppColors.onSurface,
                      ).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      countText,
                      style: AppTypography.labelSm(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Auto locate button
              if (onAutoLocatePressed != null)
                InkWell(
                  onTap: onAutoLocatePressed,
                  borderRadius: BorderRadius.circular(AppRadii.full),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.spaceSm,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.brandMintSurface,
                      borderRadius: BorderRadius.circular(AppRadii.full),
                      border: Border.all(
                        color: AppColors.brandMintBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.my_location,
                          size: 14,
                          color: AppColors.brandEmeraldDark,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'branch_selection.auto_locate'.tr(),
                          style: AppTypography.labelSm(
                            color: AppColors.brandEmeraldDark,
                          ).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          AppSpacing.vSpaceMd,

          // Main headline
          Text(
            'branch_selection.headline'.tr(),
            style: AppTypography.headlineMd(
              color: AppColors.onSurface,
            ).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          AppSpacing.vSpace2xs,

          // Supporting subtitle
          Text(
            'branch_selection.subheadline'.tr(),
            style: AppTypography.bodySm(
              color: AppColors.onSurfaceVariant,
            ).copyWith(
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
