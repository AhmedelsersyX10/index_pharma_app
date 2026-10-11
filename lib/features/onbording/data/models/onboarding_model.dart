import 'package:flutter/material.dart';
import 'package:index_pharma_store/core/utils/app_images.dart';

class OnboardingModel {
  final String image;
  final String badgeLabel;
  final IconData badgeIcon;
  final String title;
  final String description;
  final String perkText;

  const OnboardingModel({
    required this.image,
    required this.badgeLabel,
    required this.badgeIcon,
    required this.title,
    required this.description,
    required this.perkText,
  });

  static const List<OnboardingModel> defaultPages = [
    OnboardingModel(
      image: AppImages.onboarding1,
      badgeLabel: 'Verified Healthcare',
      badgeIcon: Icons.local_pharmacy_rounded,
      title: 'Your Pharmacy,\nAnytime & Anywhere',
      description:
          'Quickly order authentic medications and healthcare essentials with licensed pharmacist support around the clock.',
      perkText: '✓ 10,000+ Genuine Products  •  ✓ Licensed Support',
    ),
    OnboardingModel(
      image: AppImages.onboarding2,
      badgeLabel: 'Smart Rx Scanner',
      badgeIcon: Icons.document_scanner_rounded,
      title: 'Upload & Process\nPrescriptions Quickly',
      description:
          'Snap a clear photo of your doctor\'s prescription. Our clinical team verifies potency, dosage, and fulfills your order.',
      perkText: '✓ Instant Rx Verification  •  ✓ Clinical Review',
    ),
    OnboardingModel(
      image: AppImages.onboarding3,
      badgeLabel: 'Express & Safe Delivery',
      badgeIcon: Icons.delivery_dining_rounded,
      title: 'Fast & Secure Delivery\nRight to Your Door',
      description:
          'Real-time temperature-monitored tracking ensures your medications arrive with clinical integrity and speed.',
      perkText: '✓ Cold-chain Protection  •  ✓ Real-time Tracking',
    ),
  ];
}
