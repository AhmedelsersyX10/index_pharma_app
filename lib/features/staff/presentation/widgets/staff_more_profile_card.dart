import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/core/widgets/app_card.dart';
import 'package:index_pharma/features/auth/domain/entities/user.dart';

/// Staff profile overview card displayed on the More / Account screen (Stitch G11).
class StaffMoreProfileCard extends StatelessWidget {
  const StaffMoreProfileCard({
    super.key,
    required this.user,
  });

  final UserEntity? user;

  String _roleLabel(UserRole? role) {
    return switch (role) {
      UserRole.pharmacist => AppLocaleKeys.staffRolePharmacist.tr(),
      UserRole.admin => AppLocaleKeys.staffRoleAdmin.tr(),
      UserRole.superadmin => AppLocaleKeys.staffRoleSuperadmin.tr(),
      _ => AppLocaleKeys.staffRoleStaff.tr(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final name = user?.name.trim().isNotEmpty == true ? user!.name : 'Staff Member';
    final initial = name.characters.first.toUpperCase();
    final isSuperadmin = user?.role == UserRole.superadmin;
    final branchId = user?.branchId;
    final branchDisplay = (branchId != null && branchId.isNotEmpty)
        ? branchId
        : AppLocaleKeys.staffAllBranches.tr();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceMd),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.spaceMd),
        child: Column(
          children: [
            Row(
              children: [
                // Initials Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colors.primaryContainer,
                  child: Text(
                    initial,
                    style: AppTypography.headlineMd(color: colors.primary).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.spaceMd),

                // Name & Role & Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTypography.titleMd(color: colors.onSurface).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // Role Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.1),
                              borderRadius: AppRadii.roundedFull,
                            ),
                            child: Text(
                              _roleLabel(user?.role),
                              style: AppTypography.labelSm(color: colors.primary).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),

                          // Active Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: context.clinicalTheme.medicalGreen.withValues(alpha: 0.15),
                              borderRadius: AppRadii.roundedFull,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: context.clinicalTheme.medicalGreen,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  AppLocaleKeys.staffStatusActive.tr(),
                                  style: AppTypography.labelSm(color: context.clinicalTheme.medicalGreen).copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spaceSm),
            const Divider(),
            const SizedBox(height: 4),

            // Branch Row
            Row(
              children: [
                Icon(
                  Icons.storefront_outlined,
                  size: 18,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    branchDisplay,
                    style: AppTypography.bodySm(color: colors.onSurfaceVariant),
                  ),
                ),
                if (isSuperadmin)
                  TextButton.icon(
                    onPressed: () => context.go(AppRouter.kBranchManagementView),
                    icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                    label: Text(AppLocaleKeys.staffChangeBranch.tr()),
                    style: TextButton.styleFrom(
                      foregroundColor: colors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
