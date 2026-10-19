import 'package:flutter/material.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:index_pharma/features/onboarding/presentation/widgets/onboarding_view_body.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({
    super.key,
    this.storageService,
  });

  final StorageService? storageService;

  @override
  Widget build(BuildContext context) {
    return OnboardingViewBody(
      storageService: storageService,
    );
  }
}
