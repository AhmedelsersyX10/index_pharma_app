import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/errors/failure_mapper.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Loading shimmer/indicator view for branch list.
class BranchLoadingView extends StatelessWidget {
  const BranchLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceLg),
      itemCount: 3,
      separatorBuilder: (_, _) => AppSpacing.vSpaceMd,
      itemBuilder: (context, index) {
        return Container(
          height: 140,
          padding: const EdgeInsets.all(AppSpacing.spaceMd),
          decoration: BoxDecoration(
            color: AppColors.canvasPure,
            borderRadius: BorderRadius.circular(AppRadii.xl),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spaceSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 140,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 80,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Empty state view when no branches are returned by the server.
class BranchEmptyView extends StatelessWidget {
  const BranchEmptyView({
    super.key,
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space2xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.store_mall_directory_outlined,
                size: 36,
                color: AppColors.secondaryMuted,
              ),
            ),
            AppSpacing.vSpaceMd,
            Text(
              'branch_selection.empty_branches_title'.tr(),
              style: AppTypography.titleMd(
                color: AppColors.onSurface,
              ).copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vSpaceXs,
            Text(
              'branch_selection.empty_branches_desc'.tr(),
              style: AppTypography.bodySm(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vSpaceLg,
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text('common.retry'.tr()),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error view displaying failure message and a retry button.
class BranchErrorView extends StatelessWidget {
  const BranchErrorView({
    super.key,
    required this.failure,
    required this.onRetry,
  });

  final Failure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final errorMessage = FailureMapper.toMessage(
      failure,
      defaultFallback: 'branch_selection.fetch_error_desc'.tr(),
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space2xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: AppColors.error,
              ),
            ),
            AppSpacing.vSpaceMd,
            Text(
              'branch_selection.fetch_error_title'.tr(),
              style: AppTypography.titleMd(
                color: AppColors.onSurface,
              ).copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vSpaceXs,
            Text(
              errorMessage,
              style: AppTypography.bodySm(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vSpaceLg,
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text('common.retry'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
