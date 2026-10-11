import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:index_pharma_store/core/theme/theme.dart';
import 'package:index_pharma_store/features/onbording/data/models/onboarding_model.dart';
import 'package:index_pharma_store/features/onbording/presentation/widgets/onboarding_bottom_section.dart';
import 'package:index_pharma_store/features/onbording/presentation/widgets/onboarding_page_item.dart';
import 'package:index_pharma_store/features/onbording/presentation/widgets/onboarding_top_bar.dart';

class OnboardingViewBody extends StatefulWidget {
  final List<OnboardingModel> pages;

  const OnboardingViewBody({
    super.key,
    this.pages = OnboardingModel.defaultPages,
  });

  @override
  State<OnboardingViewBody> createState() => _OnboardingViewBodyState();
}

class _OnboardingViewBodyState extends State<OnboardingViewBody> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<OnboardingModel> get _pages => widget.pages;

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _onDone();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _onSkip() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onDone() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.spaceMd),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.primaryBrand,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.gutterSm),
            Expanded(
              child: Text(
                'Welcome to Index Pharma!',
                style: AppTypography.labelLg(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSignIn() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.spaceMd),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
        content: Row(
          children: [
            const Icon(
              Icons.login_rounded,
              color: AppColors.primaryBrand,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.gutterSm),
            Expanded(
              child: Text(
                'Navigating to Sign In...',
                style: AppTypography.labelLg(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Top Bar Header: Step chip + Skip button
              OnboardingTopBar(
                currentPage: _currentPage,
                totalPages: _pages.length,
                onSkip: _onSkip,
              ),

              // PageView Illustration & Content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return OnboardingPageItem(model: _pages[index]);
                  },
                ),
              ),

              // Bottom Navigation Dock: Indicators + Action buttons
              OnboardingBottomSection(
                currentPage: _currentPage,
                totalPages: _pages.length,
                onNext: _nextPage,
                onPrevious: _previousPage,
                onDone: _onDone,
                onSignIn: _onSignIn,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
