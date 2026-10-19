import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/features/choose_branches/domain/entities/branch_entity.dart';

/// Floating bottom confirmation bar displaying the currently approved branch
/// and the primary confirmation button.
class BranchBottomBar extends StatelessWidget {
  const BranchBottomBar({
    super.key,
    required this.selectedBranch,
    required this.onConfirm,
  });

  final BranchEntity? selectedBranch;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final bool hasSelection = selectedBranch != null;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.spaceLg,
        right: AppSpacing.spaceLg,
        top: AppSpacing.spaceMd,
        bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.spaceMd,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.08),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Selected branch label and status summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        'branch_selection.approved_branch'.tr(),
                        style: AppTypography.bodySm(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hasSelection
                              ? selectedBranch!.name
                              : 'branch_selection.select_branch_prompt'.tr(),
                          style: AppTypography.bodySm(
                            color: hasSelection
                                ? AppColors.onSurface
                                : AppColors.onSurfaceVariant,
                          ).copyWith(
                            fontWeight: hasSelection
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasSelection)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.brandEmeraldDark,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'branch_selection.available_now'.tr(),
                        style: AppTypography.labelSm(
                          color: AppColors.brandEmeraldDark,
                        ).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          AppSpacing.vSpaceSm,

          // Full width primary confirmation button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: hasSelection ? onConfirm : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.surfaceContainerHigh,
                foregroundColor: AppColors.onPrimary,
                disabledForegroundColor: AppColors.onSurfaceVariant,
                elevation: hasSelection ? 2 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'branch_selection.confirm_and_continue'.tr(),
                    style: AppTypography.labelLg(
                      color: hasSelection
                          ? AppColors.onPrimary
                          : AppColors.onSurfaceVariant,
                    ).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spaceSm),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: hasSelection
                        ? AppColors.onPrimary
                        : AppColors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
