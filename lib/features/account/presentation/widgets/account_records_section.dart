import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';

/// Clinical & Orders Hub section for the account screen (Stitch D5).
class AccountRecordsSection extends StatelessWidget {
  const AccountRecordsSection({
    super.key,
    required this.branchName,
    this.onChangeBranchTap,
  });

  final String? branchName;
  final VoidCallback? onChangeBranchTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final activeBranch = branchName ?? AppLocaleKeys.accountNotSet.tr();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            AppLocaleKeys.accountSectionRecords.tr(),
            style: AppTypography.labelMd(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.borderSubtle.withValues(alpha: 0.6),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x080B1C30),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Orders Link
              _ActionTile(
                key: const ValueKey('account_orders_tile'),
                icon: Icons.receipt_long_outlined,
                title: AppLocaleKeys.accountMyOrdersTitle.tr(),
                subtitle: AppLocaleKeys.accountMyOrdersDesc.tr(),
                onTap: () => context.push(AppRouter.kOrdersView),
              ),
              Divider(height: 1, color: colors.surfaceContainerLow),

              // Prescriptions Link
              _ActionTile(
                key: const ValueKey('account_prescriptions_tile'),
                icon: Icons.description_outlined,
                title: AppLocaleKeys.accountPrescriptionsTitle.tr(),
                subtitle: AppLocaleKeys.accountPrescriptionsDesc.tr(),
                onTap: () => context.push(AppRouter.kPrescriptionView),
              ),
              Divider(height: 1, color: colors.surfaceContainerLow),

              // Preferred Branch
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: colors.surfaceContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.storefront_outlined,
                            color: colors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocaleKeys.accountPreferredBranchTitle.tr(),
                                style: AppTypography.titleMd(
                                  color: colors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                AppLocaleKeys.accountPreferredBranchDesc.tr(),
                                style: AppTypography.bodySm(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              activeBranch,
                              style: AppTypography.labelMd(
                                color: colors.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton(
                            key: const ValueKey('account_change_branch_btn'),
                            onPressed: onChangeBranchTap ??
                                () => context.push(AppRouter.kBranchSelectionView),
                            style: TextButton.styleFrom(
                              foregroundColor: colors.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              minimumSize: const Size(0, 32),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              AppLocaleKeys.accountChangeBranch.tr(),
                              style: AppTypography.labelSm(
                                color: colors.primary,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: colors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMd(
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySm(
                      color: colors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_left_rounded,
              color: colors.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
