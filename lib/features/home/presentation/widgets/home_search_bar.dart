import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Clinical Search Bar for B2 Home Screen.
///
/// Complies with design constraints:
/// - Barcode scanner icon is REMOVED (deferred).
/// - Clean, accessible search field with search icon.
/// - Tapping or submitting navigates to `/browse`.
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,
    this.onSubmitted,
    this.onTap,
  });

  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadii.roundedLg,
        boxShadow: AppShadows.level1,
        border: Border.all(
          color: AppColors.borderSubtle,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () => context.go('/browse'),
          borderRadius: AppRadii.roundedLg,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spaceSm,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: AppColors.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.spaceSm),
                Expanded(
                  child: Text(
                    AppLocaleKeys.homeSearchHint.tr(),
                    style: AppTypography.bodyMd(
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
