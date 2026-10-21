import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Primary action button on Language Selection Screen (Stitch A3).
///
/// Triggers application and persistence of selected language choice.
class LanguageActionButton extends StatelessWidget {
  const LanguageActionButton({
    super.key,
    required this.selectedLocale,
    required this.isApplying,
    required this.onPressed,
  });

  final String selectedLocale;
  final bool isApplying;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isArabic = selectedLocale == 'ar';
    final label = isArabic
        ? AppLocaleKeys.languageContinueArabic.tr()
        : AppLocaleKeys.languageContinueEnglish.tr();

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        key: const ValueKey('language_submit_button'),
        onPressed: isApplying ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: isApplying
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: AppTypography.labelLg(
                      color: Colors.white,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ],
              ),
      ),
    );
  }
}
