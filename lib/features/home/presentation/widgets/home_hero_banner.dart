import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Customer introduction uses approved localized copy. Public marketing settings
/// are not verified claims and must not override this presentation policy.
class HomeHeroBanner extends StatelessWidget {
  const HomeHeroBanner({super.key, this.onShopNow});
  final VoidCallback? onShopNow;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: AppRadii.roundedXl,
        boxShadow: context.shadowsLevel1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocaleKeys.homeHeroTitleDefault.tr(),
            style: AppTypography.headlineLgMobile(
              color: colors.onPrimaryContainer,
            ),
          ),
          AppSpacing.vSpaceSm,
          Text(
            AppLocaleKeys.homeHeroDescDefault.tr(),
            style: AppTypography.bodyMd(color: colors.onPrimaryContainer),
          ),
          AppSpacing.vSpaceMd,
          FilledButton.icon(
            onPressed: onShopNow ?? () => context.go(AppRouter.browsePath()),
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(AppLocaleKeys.homeHeroCta.tr()),
          ),
        ],
      ),
    );
  }
}
