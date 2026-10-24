import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/core/widgets/app_card.dart';

/// Quick actions section on the Staff Home Screen (Stitch E1).
///
/// Features:
/// 1. Hero POS Action Card (full-width)
/// 2. Two-column grid with Online Orders & Prescription Review
class StaffQuickActions extends StatelessWidget {
  const StaffQuickActions({super.key});

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocaleKeys.staffActionAvailableSoon.tr()),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Hero POS Card
          AppCard(
            isInteractive: true,
            onTap: () => _showComingSoon(context),
            padding: const EdgeInsets.all(AppSpacing.spaceMd),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: AppRadii.roundedMd,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.point_of_sale_rounded,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: AppSpacing.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocaleKeys.staffHomePosCta.tr(),
                        style: AppTypography.titleMd(color: colors.onSurface).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppLocaleKeys.staffHomePosSub.tr(),
                        style: AppTypography.bodySm(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.spaceMd),

          // 2. 2-Column Row for Orders & Prescriptions
          Row(
            children: [
              // Online Orders
              Expanded(
                child: AppCard(
                  isInteractive: true,
                  onTap: () => context.go(AppRouter.kStaffOrdersView),
                  padding: const EdgeInsets.all(AppSpacing.spaceMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors.primaryContainer.withValues(alpha: 0.5),
                          borderRadius: AppRadii.roundedMd,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.receipt_long_outlined,
                          size: 22,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spaceSm),
                      Text(
                        AppLocaleKeys.staffHomeOnlineOrdersCta.tr(),
                        style: AppTypography.labelLg(color: colors.onSurface).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppLocaleKeys.staffHomeOnlineOrdersSub.tr(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelSm(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.spaceMd),

              // Prescriptions
              Expanded(
                child: AppCard(
                  isInteractive: true,
                  onTap: () => context.go(AppRouter.kStaffPrescriptionsView),
                  padding: const EdgeInsets.all(AppSpacing.spaceMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors.secondaryContainer.withValues(alpha: 0.5),
                          borderRadius: AppRadii.roundedMd,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.medication_outlined,
                          size: 22,
                          color: colors.secondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spaceSm),
                      Text(
                        AppLocaleKeys.staffHomePrescriptionsCta.tr(),
                        style: AppTypography.labelLg(color: colors.onSurface).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppLocaleKeys.staffHomePrescriptionsSub.tr(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelSm(color: colors.onSurfaceVariant),
                      ),
                    ],
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
