import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/di/service_locator.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/features/onbording/data/models/onboarding_model.dart';
import 'package:index_pharma/features/onbording/presentation/widgets/onboarding_bottom_section.dart';
import 'package:index_pharma/features/onbording/presentation/widgets/onboarding_page_item.dart';
import 'package:index_pharma/features/onbording/presentation/widgets/onboarding_top_bar.dart';

class OnboardingViewBody extends StatefulWidget {
  final List<OnboardingModel> pages;
  final StorageService? storageService;

  const OnboardingViewBody({
    super.key,
    this.pages = OnboardingModel.defaultPages,
    this.storageService,
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
      _onRegister();
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

  Future<void> _markOnboardingSeenAndNavigate(String targetRoute) async {
    final storage = widget.storageService ??
        (getIt.isRegistered<StorageService>()
            ? getIt<StorageService>()
            : null);
    await storage?.setOnboardingSeen(true);

    if (!mounted) return;
    context.go(targetRoute);
  }

  void _onRegister() {
    _markOnboardingSeenAndNavigate(AppRouter.kRegisterView);
  }

  void _onSignIn() {
    _markOnboardingSeenAndNavigate(AppRouter.kLoginView);
  }

  void _onDone() {
    _onRegister();
  }

  void _onExplore() {
    _markOnboardingSeenAndNavigate(AppRouter.kStoreView);
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
                onRegister: _onRegister,
                onExplore: _onExplore,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
