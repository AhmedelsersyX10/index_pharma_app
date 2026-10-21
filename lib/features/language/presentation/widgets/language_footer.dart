import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Trust and copyright footer for Language Selection Screen (Stitch A3).
class LanguageFooter extends StatelessWidget {
  const LanguageFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.verified_user_rounded,
              size: 14,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              AppLocaleKeys.languageFooterTrust.tr(),
              style: AppTypography.labelSm(
                color: AppColors.secondary,
              ).copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          AppLocaleKeys.languageFooterCopyright.tr(),
          style: AppTypography.bodySm(
            color: AppColors.onSurfaceVariant,
          ).copyWith(fontSize: 11),
        ),
      ],
    );
  }
}
