import 'package:flutter/material.dart';
import 'package:index_pharma_store/core/theme/theme.dart';
import 'package:index_pharma_store/core/utils/app_images.dart';
import 'package:index_pharma_store/core/widgets/widgets.dart';

class OnboardingViewBody extends StatefulWidget {
  const OnboardingViewBody({super.key});

  @override
  State<OnboardingViewBody> createState() => _OnboardingViewBodyState();
}

class _OnboardingViewBodyState extends State<OnboardingViewBody> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingModel> _pages = const [
    OnboardingModel(
      image: AppImages.onboarding1,
      title: 'Welcome to\nYour Pharmacy,\nAnywhere',
      description: 'Quickly order medications and\nhealthcare essentials.',
      buttonLabel: 'Get Started',
      isLast: false,
      isFirst: true,
    ),
    OnboardingModel(
      image: AppImages.onboarding2,
      title: 'Upload\nPrescriptions',
      description: 'Snap a photo of your paper\nprescription and we\'ll handle\nthe rest.',
      buttonLabel: 'Next',
      isLast: false,
      isFirst: false,
    ),
    OnboardingModel(
      image: AppImages.onboarding3,
      title: 'Delivery to\nYour Door',
      description: 'Track your meds from the store\nto your home, safely.',
      buttonLabel: 'Done',
      isLast: true,
      isFirst: false,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _onDone();
    }
  }

  void _onDone() {}

  void _onSkip() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Page indicator dots - top
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.spaceLg),
              child: _buildDotIndicator(),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _OnboardingPage(model: _pages[index]);
                },
              ),
            ),

            // Bottom buttons
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDotIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: _currentPage == index ? 24 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: _currentPage == index ? AppColors.primaryBrand : AppColors.slate200,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    final currentModel = _pages[_currentPage];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceXl,
        vertical: AppSpacing.spaceLg,
      ),
      child: Column(
        children: [
          // Main CTA button
          AppButton.primary(text: currentModel.buttonLabel, onPressed: _nextPage, height: 54),

          const SizedBox(height: AppSpacing.gutterSm),

          // Second button (Skip / Let's Go! / Login or Explore)
          if (currentModel.isFirst)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Login', style: AppTypography.labelLg(color: AppColors.primaryBrand)),
                  Text(' or ', style: AppTypography.bodyMd(color: AppColors.slate500)),
                  Text('Explore', style: AppTypography.labelLg(color: AppColors.primaryBrand)),
                ],
              ),
            )
          else if (!currentModel.isLast)
            SizedBox(
              width: double.infinity,
              height: 54,
              child: TextButton(
                onPressed: _onSkip,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryBrand,
                  shape: const StadiumBorder(),
                ),
                child: Text('Skip', style: AppTypography.labelLg(color: AppColors.primaryBrand)),
              ),
            )
          else
            AppButton.outlined(text: "Let's Go!", onPressed: _onDone, height: 54),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingModel model;

  const _OnboardingPage({required this.model});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceLg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image takes available dynamic space
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceSm),
              child: ClipRRect(
                borderRadius: AppRadii.roundedXl,
                child: Image.asset(model.image, fit: BoxFit.contain),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.spaceMd),

          // Title & Description with natural height and mobile typography
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                model.title,
                textAlign: TextAlign.center,
                style: AppTypography.headlineLgMobile(color: AppColors.onSurface),
              ),
              const SizedBox(height: AppSpacing.spaceSm),
              Text(
                model.description,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMd(color: AppColors.slate500),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceSm),
        ],
      ),
    );
  }
}

class OnboardingModel {
  final String image;
  final String title;
  final String description;
  final String buttonLabel;
  final bool isLast;
  final bool isFirst;

  const OnboardingModel({
    required this.image,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.isLast,
    required this.isFirst,
  });
}
