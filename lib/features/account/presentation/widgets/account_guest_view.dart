import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';

/// Guest Mode presentation for Customer Account screen (Stitch D5).
class AccountGuestView extends StatelessWidget {
  const AccountGuestView({
    super.key,
    required this.storageService,
  });

  final StorageService storageService;

  Future<void> _toggleLanguage(BuildContext context) async {
    final currentCode = context.locale.languageCode;
    final targetLocale =
        currentCode == 'ar' ? const Locale('en') : const Locale('ar');
    await context.setLocale(targetLocale);
    await storageService.setLocale(targetLocale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    final langBadgeText = isArabic
        ? AppLocaleKeys.accountLangArabic.tr()
        : AppLocaleKeys.accountLangEnglish.tr();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Guest Hero Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderSubtle.withValues(alpha: 0.6),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x080B1C30),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: AppColors.brandMintSurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_pharmacy_rounded,
                  size: 30,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                AppLocaleKeys.accountGuestWelcomeTitle.tr(),
                style: AppTypography.headlineMd(
                  color: AppColors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocaleKeys.accountGuestWelcomeDesc.tr(),
                style: AppTypography.bodyMd(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // CTA Buttons
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  key: const ValueKey('guest_login_button'),
                  onPressed: () => context.push(AppRouter.kLoginView),
                  icon: const Icon(Icons.login_rounded, size: 20),
                  label: Text(
                    AppLocaleKeys.accountGuestLoginBtn.tr(),
                    style: AppTypography.labelLg(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  key: const ValueKey('guest_register_button'),
                  onPressed: () => context.push(AppRouter.kRegisterView),
                  icon: const Icon(Icons.person_add_outlined, size: 20),
                  label: Text(
                    AppLocaleKeys.accountGuestRegisterBtn.tr(),
                    style: AppTypography.labelLg(
                      color: AppColors.primary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Benefits Cards
        Row(
          children: [
            Expanded(
              child: _BenefitCard(
                icon: Icons.alarm_rounded,
                title: AppLocaleKeys.accountGuestBenefitRemindersTitle.tr(),
                desc: AppLocaleKeys.accountGuestBenefitRemindersDesc.tr(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _BenefitCard(
                icon: Icons.note_alt_outlined,
                title: AppLocaleKeys.accountGuestBenefitArchiveTitle.tr(),
                desc: AppLocaleKeys.accountGuestBenefitArchiveDesc.tr(),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Pharmacy & Service Information Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            AppLocaleKeys.accountGuestSectionInfo.tr(),
            style: AppTypography.labelMd(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderSubtle.withValues(alpha: 0.6),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x080B1C30),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Language Switcher Tile for Guests
              InkWell(
                key: const ValueKey('guest_language_switch_tile'),
                onTap: () => _toggleLanguage(context),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.translate_rounded,
                          color: AppColors.onSecondaryContainer,
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
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppLocaleKeys.accountLanguageDesc.tr(),
                              style: AppTypography.bodySm(
                                color: AppColors.onSurfaceVariant,
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
                          color: AppColors.brandMintSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.brandMintBorder,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              langBadgeText,
                              style: AppTypography.labelSm(
                                color: AppColors.brandEmeraldDark,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.swap_horiz_rounded,
                              size: 16,
                              color: AppColors.brandEmeraldDark,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: AppColors.surfaceContainerLow),

              // About Index Pharma
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocaleKeys.accountGuestAboutTitle.tr(),
                            style: AppTypography.titleMd(
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppLocaleKeys.accountGuestAboutDesc.tr(),
                            style: AppTypography.bodySm(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.surfaceContainerLow),

              // Licensing info
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.gavel_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocaleKeys.accountLicensingTitle.tr(),
                            style: AppTypography.titleMd(
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppLocaleKeys.accountLicensingDesc.tr(),
                            style: AppTypography.bodySm(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Support Footer
        Text(
          AppLocaleKeys.accountGuestSupportFooter.tr(),
          style: AppTypography.bodySm(
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          AppLocaleKeys.accountVersionFooter.tr(),
          style: AppTypography.labelSm(
            color: AppColors.outline,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _BenefitCard extends StatelessWidget {
  const _BenefitCard({
    required this.icon,
    required this.title,
    required this.desc,
  });

  final IconData icon;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderSubtle.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080B1C30),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.brandMintSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.brandEmeraldDark, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTypography.titleMd(color: AppColors.onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
