import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Clinical security and confidentiality micro-notes for authentication screens.
class ClinicalTrustFooter extends StatelessWidget {
  final bool isDetailed;

  const ClinicalTrustFooter({super.key, this.isDetailed = false});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (isDetailed) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.spaceSm),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: AppRadii.roundedXl,
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colors.brandMintSurface,
                borderRadius: AppRadii.roundedLg,
              ),
              child: Icon(
                Icons.verified_user_outlined,
                color: colors.brandEmeraldDark,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.spaceSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocaleKeys.authMedicalConfidentialityTitle.tr(),
                    style: AppTypography.titleMd(color: colors.onSurface),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppLocaleKeys.authMedicalConfidentialityDesc.tr(),
                    style: AppTypography.bodySm(color: colors.slate600),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceMd),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined, size: 16, color: colors.slate500),
          const SizedBox(width: AppSpacing.space2xs),
          Flexible(
            child: Text(
              AppLocaleKeys.authDataSecurityNote.tr(),
              style: AppTypography.labelSm(color: colors.slate500),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
