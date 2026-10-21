import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import '../cubit/language_cubit.dart';
import '../cubit/language_state.dart';
import '../widgets/language_action_button.dart';
import '../widgets/language_assurance_card.dart';
import '../widgets/language_footer.dart';
import '../widgets/language_hero_header.dart';
import '../widgets/language_selection_card.dart';
import '../widgets/language_top_bar.dart';

/// Language Selection Screen built to specifications of Stitch design A3.
///
/// Features:
/// - Clinical Clarity aesthetic with ambient tonal containment and soft elevation.
/// - Immediate interactive candidate selection between Arabic (RTL) and English (LTR).
/// - Choice application via [EasyLocalization] and persistence via [StorageService].
/// - Dynamic routing: Gateway before onboarding on first run, or dismissible modal/view
///   when invoked from Account Settings.
class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({
    super.key,
    this.cubit,
    this.storageService,
    this.from,
  });

  final LanguageCubit? cubit;
  final StorageService? storageService;
  final String? from;

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  late final LanguageCubit _cubit;
  late final StorageService? _storageService;
  bool _ownsCubit = false;

  @override
  void initState() {
    super.initState();
    _storageService = widget.storageService ??
        (GetIt.instance.isRegistered<StorageService>()
            ? GetIt.instance<StorageService>()
            : null);

    if (widget.cubit != null) {
      _cubit = widget.cubit!;
    } else {
      _cubit = LanguageCubit(
        storageService: _storageService,
      );
      _ownsCubit = true;
    }
  }

  @override
  void dispose() {
    if (_ownsCubit) {
      _cubit.close();
    }
    super.dispose();
  }

  bool get _isFromAccount => widget.from == 'account';

  Future<void> _handleConfirm(String targetLocale) async {
    await _cubit.persistSelection(targetLocale);
    if (!mounted) return;

    await context.setLocale(Locale(targetLocale));
    if (!mounted) return;

    if (_isFromAccount) {
      context.pop();
    } else {
      context.go(AppRouter.kOnboardingView);
    }
  }

  Future<void> _handleSkip() async {
    // Skip defaults to Arabic if no preference stored
    final target = _storageService?.locale ?? 'ar';
    await _cubit.persistSelection(target);
    if (!mounted) return;

    await context.setLocale(Locale(target));
    if (!mounted) return;

    if (_isFromAccount) {
      context.pop();
    } else {
      context.go(AppRouter.kOnboardingView);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      bloc: _cubit,
      builder: (context, state) {
        final isArabicSelected = state.selectedLocale == 'ar';
        final isEnglishSelected = state.selectedLocale == 'en';

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
          ),
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    // Top Bar (Version chip + Skip / Back action)
                    LanguageTopBar(
                      isFromAccount: _isFromAccount,
                      onSkip: _handleSkip,
                      onBack: () => context.pop(),
                    ),

                    const SizedBox(height: 12),

                    // Hero Header & Emblem
                    const LanguageHeroHeader(),

                    const SizedBox(height: 20),

                    // Option 1: Arabic Card
                    LanguageSelectionCard(
                      languageCode: 'ar',
                      isSelected: isArabicSelected,
                      onTap: () => _cubit.selectLanguage('ar'),
                      iconText: AppLocaleKeys.languageArabicIcon.tr(),
                      title: AppLocaleKeys.languageArabicTitle.tr(),
                      badge: AppLocaleKeys.languageArabicBadge.tr(),
                      slogan: AppLocaleKeys.languageArabicSlogan.tr(),
                      description: AppLocaleKeys.languageArabicDesc.tr(),
                      tagIcon: Icons.verified_rounded,
                      tagText: AppLocaleKeys.languageArabicTag.tr(),
                      tagTrailing: AppLocaleKeys.languageArabicRecommended.tr(),
                      isRecommended: true,
                    ),

                    const SizedBox(height: 12),

                    // Option 2: English Card
                    LanguageSelectionCard(
                      languageCode: 'en',
                      isSelected: isEnglishSelected,
                      onTap: () => _cubit.selectLanguage('en'),
                      iconText: 'En',
                      title: AppLocaleKeys.languageEnglishTitle.tr(),
                      badge: AppLocaleKeys.languageEnglishBadge.tr(),
                      slogan: AppLocaleKeys.languageEnglishSlogan.tr(),
                      description: AppLocaleKeys.languageEnglishDesc.tr(),
                      tagIcon: Icons.format_align_left_rounded,
                      tagText: AppLocaleKeys.languageEnglishTag.tr(),
                      tagTrailing: AppLocaleKeys.languageEnglishUniversal.tr(),
                      isRecommended: false,
                    ),

                    const SizedBox(height: 16),

                    // Clinical Assurance Box
                    const LanguageAssuranceCard(),

                    const SizedBox(height: 24),

                    // Primary Action Button
                    LanguageActionButton(
                      selectedLocale: state.selectedLocale,
                      isApplying: state.isApplying,
                      onPressed: () => _handleConfirm(state.selectedLocale),
                    ),

                    const SizedBox(height: 16),

                    // Footer Trust Note
                    const LanguageFooter(),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
