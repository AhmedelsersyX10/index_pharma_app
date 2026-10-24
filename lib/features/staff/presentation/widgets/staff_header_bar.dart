import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/features/auth/domain/entities/user.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_state.dart';

/// Top header bar for the Staff Home Screen (Stitch E1).
///
/// Displays:
/// - Branch name chip (or "All Branches" / fallback)
/// - Shift status pill (inactive)
/// - Branch change action (superadmin only)
class StaffHeaderBar extends StatelessWidget {
  const StaffHeaderBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final authState = context.watch<AuthCubit>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    final isSuperadmin = user?.role == UserRole.superadmin;
    final branchDisplay = (user?.branchId != null && user!.branchId!.isNotEmpty)
        ? user.branchId!
        : AppLocaleKeys.staffAllBranches.tr();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceMd, vertical: AppSpacing.spaceSm),
      child: Row(
        children: [
          // Branch Chip
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: AppRadii.roundedFull,
                border: Border.all(color: colors.borderSubtle),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.storefront_outlined,
                    size: 18,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      branchDisplay,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelMd(color: colors.onSurface).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.spaceSm),

          // Superadmin Branch Switcher Button
          if (isSuperadmin) ...[
            TextButton.icon(
              onPressed: () => context.go(AppRouter.kBranchManagementView),
              icon: const Icon(Icons.swap_horiz_rounded, size: 16),
              label: Text(AppLocaleKeys.staffChangeBranch.tr()),
              style: TextButton.styleFrom(
                foregroundColor: colors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: AppSpacing.spaceXs),
          ],

          // Shift Status Pill (inactive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.6),
              borderRadius: AppRadii.roundedFull,
              border: Border.all(color: colors.borderSubtle),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  AppLocaleKeys.staffShiftInactive.tr(),
                  style: AppTypography.labelSm(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
