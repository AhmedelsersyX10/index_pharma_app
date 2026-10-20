import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:index_pharma/features/settings/presentation/cubit/settings_state.dart';

/// Hero Clinical Banner widget for B2 Home Screen.
///
/// Features:
/// - Gradient container from `AppColors.primary` to `AppColors.brandEmeraldDark`.
/// - Regulatory compliance badge.
/// - Title and description dynamically provided by [SettingsCubit] with localized defaults.
/// - "Shop Medications Now" CTA button with navigation to `/browse`.
/// - Nationwide delivery coverage reassurance text.
class HomeHeroBanner extends StatelessWidget {
  const HomeHeroBanner({
    super.key,
    this.onShopNow,
  });

  final VoidCallback? onShopNow;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        String title = AppLocaleKeys.homeHeroTitleDefault.tr();
        String desc = AppLocaleKeys.homeHeroDescDefault.tr();

        if (state is SettingsLoaded) {
          final sTitle = state.settings.homeHeroTitle;
          final sDesc = state.settings.homeHeroDesc;
          if (sTitle != null && sTitle.trim().isNotEmpty) {
            title = sTitle.trim();
          }
          if (sDesc != null && sDesc.trim().isNotEmpty) {
            desc = sDesc.trim();
          }
        }

        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primaryContainer,
                AppColors.brandEmeraldDark,
              ],
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
            ),
            borderRadius: AppRadii.roundedXl,
            boxShadow: AppShadows.level2,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Subtle background medical cross graphic
              PositionedDirectional(
                bottom: -20,
                start: -20,
                child: Opacity(
                  opacity: 0.08,
                  child: Container(
                    width: 140,
                    height: 140,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.add_rounded,
                      size: 160,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(AppSpacing.spaceMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Regulatory Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: AppRadii.roundedFull,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified_outlined,
                            size: 14,
                            color: AppColors.brandTealBright,
                          ),
                          const SizedBox(width: AppSpacing.space2xs),
                          Text(
                            AppLocaleKeys.homeHeroBadge.tr(),
                            style: AppTypography.labelSm(
                              color: AppColors.brandTealBright,
                            ).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spaceSm),

                    // Headline
                    Text(
                      title,
                      style: AppTypography.headlineLgMobile(
                        color: Colors.white,
                      ).copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spaceXs),

                    // Description
                    Text(
                      desc,
                      style: AppTypography.bodySm(
                        color: AppColors.surfaceContainerLow,
                      ).copyWith(
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spaceMd),

                    // Actions Row
                    Wrap(
                      spacing: AppSpacing.spaceSm,
                      runSpacing: AppSpacing.spaceXs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: onShopNow ?? () => context.go('/browse'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.surfaceContainerLowest,
                            foregroundColor: AppColors.primary,
                            elevation: 0,
                            shape: const RoundedRectangleBorder(
                              borderRadius: AppRadii.roundedFull,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.spaceMd,
                              vertical: 10,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppLocaleKeys.homeHeroCta.tr(),
                                style: AppTypography.labelMd(
                                  color: AppColors.primary,
                                ).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.space2xs),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          AppLocaleKeys.homeHeroCoverage.tr(),
                          style: AppTypography.labelSm(
                            color: AppColors.tertiaryFixed,
                          ).copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
