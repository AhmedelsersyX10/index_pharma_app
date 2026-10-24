import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/widgets/app_card.dart';

/// Shift status hero card displayed on the Staff Home Screen (Stitch E1).
///
/// In V1 / Task 4.01, shifts are inactive placeholders awaiting Tasks E2–E4.
class StaffShiftStatusCard extends StatelessWidget {
  const StaffShiftStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceMd),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: AppRadii.roundedMd,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.schedule_rounded,
                    size: 24,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocaleKeys.staffHomeShiftInactive.tr(),
                        style: AppTypography.titleMd(color: colors.onSurface).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocaleKeys.staffHomeShiftInactiveSub.tr(),
                        style: AppTypography.bodySm(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spaceSm),
            const Divider(),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.verified_outlined,
                  size: 16,
                  color: context.clinicalTheme.medicalGreen,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    AppLocaleKeys.staffHomeEdaLicenseBadge.tr(),
                    style: AppTypography.labelSm(color: colors.onSurfaceVariant),
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
