import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Clinical Quality & Storage Guarantee Footer callout for B2 Home Screen.
///
/// Features:
/// - Clinical shield icon in soft primary circle.
/// - Storage integrity assurance notice.
class HomeStorageGuaranteeFooter extends StatelessWidget {
  const HomeStorageGuaranteeFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: AppRadii.roundedXl,
        border: Border.all(
          color: colors.borderSubtle,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.shield_outlined,
              size: 20,
              color: colors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocaleKeys.homeGuaranteeTitle.tr(),
                  style: AppTypography.titleMd(
                    color: colors.onSurface,
                  ).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppLocaleKeys.homeGuaranteeDesc.tr(),
                  style: AppTypography.bodySm(
                    color: colors.onSurfaceVariant,
                  ).copyWith(
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
