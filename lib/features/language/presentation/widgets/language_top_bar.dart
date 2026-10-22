import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Top bar for Language Selection Screen (Stitch A3).
///
/// Displays a certified version pill on the leading side, and a dynamic action
/// (Skip on first run, Back chevron when accessed from Account) on the trailing side.
class LanguageTopBar extends StatelessWidget {
  const LanguageTopBar({
    super.key,
    required this.isFromAccount,
    required this.onSkip,
    required this.onBack,
  });

  final bool isFromAccount;
  final VoidCallback onSkip;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(),
          if (isFromAccount)
            IconButton(
              key: const ValueKey('language_back_button'),
              icon: const Icon(Icons.arrow_forward),
              color: colors.onSurfaceVariant,
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: onBack,
            )
          else
            TextButton.icon(
              key: const ValueKey('language_skip_button'),
              onPressed: onSkip,
              iconAlignment: IconAlignment.end,
              icon: Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: colors.onSurfaceVariant,
              ),
              label: Text(
                AppLocaleKeys.languageSkip.tr(),
                style: AppTypography.labelMd(color: colors.onSurfaceVariant),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
        ],
      ),
    );
  }
}
