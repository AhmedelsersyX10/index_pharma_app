import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';

/// App preferences & medical compliance section (Stitch D5).
///
/// Houses the language switcher (persisted via [StorageService] and [easy_localization]),
/// plus medical privacy and licensing compliance information.
class AccountPreferencesSection extends StatelessWidget {
  const AccountPreferencesSection({
    super.key,
    required this.storageService,
    this.themeCubit,
  });

  final StorageService storageService;
  final ThemeCubit? themeCubit;

  Future<void> _openLanguageSelection(BuildContext context) async {
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      context.push('${AppRouter.kLanguageSelectionView}?from=account');
    } else {
      final currentCode = context.locale.languageCode;
      final targetLocale = currentCode == 'ar'
          ? const Locale('en')
          : const Locale('ar');
      await context.setLocale(targetLocale);
      await storageService.setLocale(targetLocale.languageCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isArabic = context.locale.languageCode == 'ar';
    final langBadgeText = isArabic
        ? AppLocaleKeys.accountLangArabic.tr()
        : AppLocaleKeys.accountLangEnglish.tr();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            AppLocaleKeys.accountSectionPreferences.tr(),
            style: AppTypography.labelMd(color: colors.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: 8),

        // Appearance / Theme Selection Card
        _ThemeSelectionCard(
          storageService: storageService,
          themeCubit: themeCubit,
        ),
        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.borderSubtle.withValues(alpha: 0.6),
              width: 1,
            ),
            boxShadow: context.shadowsLevel1,
          ),
          child: Column(
            children: [
              // Language Switcher Tile
              InkWell(
                key: const ValueKey('account_language_switch_tile'),
                onTap: () => _openLanguageSelection(context),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: colors.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.translate_rounded,
                          color: colors.onSecondaryContainer,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocaleKeys.accountLanguageTitle.tr(),
                              style: AppTypography.titleMd(
                                color: colors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppLocaleKeys.accountLanguageDesc.tr(),
                              style: AppTypography.bodySm(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
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
                            Text(
                              langBadgeText,
                              style: AppTypography.labelSm(
                                color: colors.brandEmeraldDark,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.swap_horiz_rounded,
                              size: 16,
                              color: colors.brandEmeraldDark,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeSelectionCard extends StatelessWidget {
  const _ThemeSelectionCard({required this.storageService, this.themeCubit});

  final StorageService storageService;
  final ThemeCubit? themeCubit;

  ThemeMode _resolveMode(BuildContext context) {
    final cubit = themeCubit ?? _maybeThemeCubit(context);
    if (cubit != null) {
      return cubit.state;
    }
    final raw = storageService.themeMode;
    if (raw == 'light') return ThemeMode.light;
    if (raw == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  static ThemeCubit? _maybeThemeCubit(BuildContext context) {
    try {
      return context.read<ThemeCubit>();
    } on Object catch (_) {
      // ThemeCubit is not available in the current context hierarchy
      return null;
    }
  }

  void _onSelect(BuildContext context, ThemeMode mode) {
    final cubit = themeCubit ?? _maybeThemeCubit(context);
    if (cubit != null) {
      cubit.updateThemeMode(mode);
    } else {
      final String str;
      switch (mode) {
        case ThemeMode.light:
          str = 'light';
          break;
        case ThemeMode.dark:
          str = 'dark';
          break;
        case ThemeMode.system:
          str = 'system';
          break;
      }
      storageService.setThemeMode(str);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = themeCubit ?? _maybeThemeCubit(context);
    if (cubit != null) {
      return BlocBuilder<ThemeCubit, ThemeMode>(
        bloc: cubit,
        builder: (context, currentMode) => _buildCard(context, currentMode),
      );
    }
    return _buildCard(context, _resolveMode(context));
  }

  Widget _buildCard(BuildContext context, ThemeMode currentMode) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.borderSubtle.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: context.shadowsLevel1,
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.palette_outlined,
                  color: colors.onSecondaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocaleKeys.accountThemeTitle.tr(),
                      style: AppTypography.titleMd(color: colors.onSurface),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppLocaleKeys.accountThemeDesc.tr(),
                      style: AppTypography.bodySm(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ThemeOptionPill(
                  key: const ValueKey('account_theme_option_light'),
                  title: AppLocaleKeys.accountThemeLight.tr(),
                  icon: Icons.light_mode_outlined,
                  isSelected: currentMode == ThemeMode.light,
                  onTap: () => _onSelect(context, ThemeMode.light),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ThemeOptionPill(
                  key: const ValueKey('account_theme_option_dark'),
                  title: AppLocaleKeys.accountThemeDark.tr(),
                  icon: Icons.dark_mode_outlined,
                  isSelected: currentMode == ThemeMode.dark,
                  onTap: () => _onSelect(context, ThemeMode.dark),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ThemeOptionPill(
                  key: const ValueKey('account_theme_option_system'),
                  title: AppLocaleKeys.accountThemeSystem.tr(),
                  icon: Icons.brightness_auto_outlined,
                  isSelected: currentMode == ThemeMode.system,
                  onTap: () => _onSelect(context, ThemeMode.system),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeOptionPill extends StatelessWidget {
  const _ThemeOptionPill({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.brandMintSurface : colors.surfaceSubtle,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colors.primaryBrand : colors.borderSubtle,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? colors.brandEmeraldDark : colors.slate500,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style:
                  AppTypography.labelSm(
                    color: isSelected
                        ? colors.brandEmeraldDark
                        : colors.onSurfaceVariant,
                  ).copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
