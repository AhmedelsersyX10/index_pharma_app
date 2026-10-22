import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Hero header section for Language Selection Screen (Stitch A3).
///
/// Features the brand logo emblem, bilingual pill tag, title headline, and subtitle.
class LanguageHeroHeader extends StatelessWidget {
  const LanguageHeroHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        // Brand Logo Emblem with subtle elevation & active green badge
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 64,
              height: 64,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.borderSubtle.withValues(alpha: 0.6),
                  width: 1,
                ),
                boxShadow: context.shadowsLevel1,
              ),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.local_pharmacy_rounded,
                  color: colors.primary,
                  size: 36,
                ),
              ),
            ),
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: colors.tertiaryFixed,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.surfaceContainerLowest,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Bilingual Experience Pill Tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: colors.brandMintSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colors.brandMintBorder,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.translate_rounded,
                size: 15,
                color: colors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                AppLocaleKeys.languageBilingualBadge.tr(),
                style: AppTypography.labelSm(
                  color: colors.brandEmeraldDark,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Main Headline Title
        Text(
          AppLocaleKeys.languageTitle.tr(),
          style: AppTypography.headlineLgMobile(
            color: colors.onSurface,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 6),

        // Reassuring Subtitle
        Text(
          AppLocaleKeys.languageSubtitle.tr(),
          style: AppTypography.bodySm(
            color: colors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
