import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
              _buildTopBar(),

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
                    return _OnboardingPage(model: _pages[index]);
                  },
                ),
              ),

              // Bottom Navigation Dock: Indicators + Action buttons
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final isLastPage = _currentPage == _pages.length - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceLg,
        vertical: AppSpacing.spaceSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Step Counter Badge
          AppBadge.neutral(
            label: 'Step ${_currentPage + 1} of ${_pages.length}',
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          ),

          // Smooth animated Skip button
          AnimatedOpacity(
            opacity: isLastPage ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: isLastPage,
              child: TextButton(
                onPressed: _onSkip,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.slate500,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Skip',
                  style: AppTypography.labelLg(color: AppColors.slate500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    final isFirstPage = _currentPage == 0;
    final isLastPage = _currentPage == _pages.length - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.spaceLg,
        AppSpacing.spaceSm,
        AppSpacing.spaceLg,
        AppSpacing.spaceLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Active Expanding Pill Indicators
          _buildDotIndicator(),

          AppSpacing.vSpaceLg,

          // Dynamic Navigation Action Controls
          if (!isLastPage) ...[
            if (isFirstPage)
              AppButton.primary(
                text: 'Get Started',
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                height: 54,
                onPressed: _nextPage,
              )
            else
              Row(
                children: [
                  // Circular Back button
                  Material(
                    color: AppColors.slate100,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: _previousPage,
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.slate200,
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.slate700,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: AppSpacing.gutterSm),

                  // Next Action Button
                  Expanded(
                    child: AppButton.primary(
                      text: 'Continue',
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      height: 54,
                      onPressed: _nextPage,
                    ),
                  ),
                ],
              ),
          ] else ...[
            // Last Page: Hero CTA + Secondary Sign In link
            AppButton.primary(
              text: 'Start Exploring',
              icon: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 18,
              ),
              height: 54,
              onPressed: _onDone,
            ),

            const SizedBox(height: AppSpacing.gutterSm),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: AppTypography.bodyMd(color: AppColors.slate500),
                ),
                GestureDetector(
                  onTap: _onSignIn,
                  child: Text(
                    'Sign In',
                    style: AppTypography.labelLg(color: AppColors.primaryBrand),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDotIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) {
          final isSelected = _currentPage == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isSelected ? 30 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBrand : AppColors.slate200,
              borderRadius: BorderRadius.circular(4),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryBrand.withValues(alpha: 0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
          );
        },
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
        children: [
          // Illustration Stage Card with Ambient Glow
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.spaceSm,
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 380),
                  decoration: BoxDecoration(
                    color: AppColors.canvasPure,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: AppColors.brandMintBorder,
                      width: 1.2,
                    ),
                    boxShadow: AppShadows.level1,
                  ),
                  padding: const EdgeInsets.all(AppSpacing.spaceLg),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      model.image,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content section (Badge, Headline, Description, Perks)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spaceSm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBadge.trust(
                  label: model.badgeLabel,
                  icon: Icon(
                    model.badgeIcon,
                    size: 14,
                    color: AppColors.brandEmeraldDark,
                  ),
                ),

                AppSpacing.vSpaceSm,

                Text(
                  model.title,
                  textAlign: TextAlign.center,
                  style: AppTypography.displayLgMobile(
                    color: AppColors.secondary,
                  ).copyWith(
                    height: 1.22,
                  ),
                ),

                AppSpacing.vSpaceSm,

                Text(
                  model.description,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMd(
                    color: AppColors.slate500,
                  ).copyWith(
                    height: 1.45,
                  ),
                ),

                AppSpacing.vSpaceSm,

                Text(
                  model.perkText,
                  textAlign: TextAlign.center,
                  style: AppTypography.labelSm(
                    color: AppColors.brandEmeraldDark,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.spaceSm),
        ],
      ),
    );
  }
}

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
}

