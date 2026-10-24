import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Introductory header section displaying geographic coverage, branch count,
/// and contextual purpose of branch selection.
class BranchIntroSection extends StatelessWidget {
  const BranchIntroSection({super.key, required this.branchesCount});

  final int branchesCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final countText = branchesCount == 1
        ? 'branch_selection.single_active_branch'.tr()
        : 'branch_selection.active_branches_count'.tr(
            args: [branchesCount.toString()],
          );

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
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, size: 16, color: colors.primary),
                    const SizedBox(width: AppSpacing.space2xs),
                    Text(
                      'branch_selection.region_title'.tr(),
                      style: AppTypography.labelMd(
                        color: colors.onSurface,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      countText,
                      style: AppTypography.labelSm(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          AppSpacing.vSpaceMd,

          // Main headline
          Text(
            'branch_selection.headline'.tr(),
            style: AppTypography.headlineMd(
              color: colors.onSurface,
            ).copyWith(fontWeight: FontWeight.w700),
          ),

          AppSpacing.vSpace2xs,

          // Supporting subtitle
          Text(
            'branch_selection.subheadline'.tr(),
            style: AppTypography.bodySm(
              color: colors.onSurfaceVariant,
            ).copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}
