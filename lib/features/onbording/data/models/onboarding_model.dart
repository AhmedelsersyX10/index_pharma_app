import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/utils/app_images.dart';

class OnboardingModel {
  final String image;
  final String badgeLabelKey;
  final IconData badgeIcon;
  final String titleKey;
  final String descriptionKey;
  final String perkTextKey;

  const OnboardingModel({
    required this.image,
    required this.badgeLabelKey,
    required this.badgeIcon,
    required this.titleKey,
    required this.descriptionKey,
    required this.perkTextKey,
  });

  String get badgeLabel => badgeLabelKey.tr();
  String get title => titleKey.tr();
  String get description => descriptionKey.tr();
  String get perkText => perkTextKey.tr();

  static const List<OnboardingModel> defaultPages = [
    OnboardingModel(
      image: AppImages.onboarding1,
      badgeLabelKey: AppLocaleKeys.onboardingPage1Badge,
      badgeIcon: Icons.local_pharmacy_rounded,
      titleKey: AppLocaleKeys.onboardingPage1Title,
      descriptionKey: AppLocaleKeys.onboardingPage1Description,
      perkTextKey: AppLocaleKeys.onboardingPage1Perk,
    ),
    OnboardingModel(
      image: AppImages.onboarding2,
      badgeLabelKey: AppLocaleKeys.onboardingPage2Badge,
      badgeIcon: Icons.document_scanner_rounded,
      titleKey: AppLocaleKeys.onboardingPage2Title,
      descriptionKey: AppLocaleKeys.onboardingPage2Description,
      perkTextKey: AppLocaleKeys.onboardingPage2Perk,
    ),
    OnboardingModel(
      image: AppImages.onboarding3,
      badgeLabelKey: AppLocaleKeys.onboardingPage3Badge,
      badgeIcon: Icons.delivery_dining_rounded,
      titleKey: AppLocaleKeys.onboardingPage3Title,
      descriptionKey: AppLocaleKeys.onboardingPage3Description,
      perkTextKey: AppLocaleKeys.onboardingPage3Perk,
    ),
  ];
}
