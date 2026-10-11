import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma_store/core/theme/theme.dart';
import 'package:index_pharma_store/core/utils/app_images.dart';
import 'package:index_pharma_store/core/utils/app_router.dart';
import 'package:index_pharma_store/core/widgets/widgets.dart';

class SplashViewBody extends StatefulWidget {
  const SplashViewBody({super.key});

  @override
  State<SplashViewBody> createState() => _SplashViewBodyState();
}

class _SplashViewBodyState extends State<SplashViewBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _textSlide;
  late final Animation<double> _textFade;
  late final Animation<double> _footerFade;
  late final Animation<double> _pulseGlow;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.05, 0.55, curve: Curves.easeOutBack),
      ),
    );

    _pulseGlow = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.85, curve: Curves.easeInOut),
      ),
    );

    _textSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
      ),
    );

    _footerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.95, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _scheduleNavigation();
  }

  void _scheduleNavigation() {
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (!mounted) return;
      context.go(AppRouter.kOnboardingView);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
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
        body: Stack(
          children: [
            // Ambient clinical background illumination
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.brandMintSurface,
                      AppColors.background,
                      AppColors.surfaceSubtle,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),

            // Soft glowing pulse behind logo
            Center(
              child: AnimatedBuilder(
                animation: _pulseGlow,
                builder: (context, child) {
                  return Container(
                    width: 250 * _pulseGlow.value,
                    height: 250 * _pulseGlow.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.brandMintBorder.withValues(alpha: 0.5),
                          AppColors.brandMintSurface.withValues(alpha: 0.15),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Main center content
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceXl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 3),

                      // Animated Logo with Ambient Elevation
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _logoFade.value,
                            child: Transform.scale(
                              scale: _logoScale.value,
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBrand.withValues(alpha: 0.22),
                                blurRadius: 36,
                                spreadRadius: 2,
                                offset: const Offset(0, 14),
                              ),
                              BoxShadow(
                                color: AppColors.secondary.withValues(alpha: 0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: Image.asset(
                              AppImages.logo,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      AppSpacing.vSpaceLg,

                      // Animated Brand Typography & Slogan
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _textFade.value,
                            child: Transform.translate(
                              offset: Offset(0, _textSlide.value),
                              child: child,
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Index',
                                  style: AppTypography.displayLgMobile(
                                    color: AppColors.secondary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Pharma',
                                  style: AppTypography.displayLgMobile(
                                    color: AppColors.primaryBrand,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(top: 14),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryBrand,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                            AppSpacing.vSpaceXs,
                            Text(
                              'Clinical Clarity & Care',
                              style: AppTypography.bodyMd(
                                color: AppColors.slate500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(flex: 3),

                      // Animated Footer (Loading indicator & Trust Badge)
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _footerFade.value,
                            child: child,
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Sleek clinical loading progress capsule
                            SizedBox(
                              width: 90,
                              height: 4,
                              child: ClipRRect(
                                borderRadius: AppRadii.roundedFull,
                                child: const LinearProgressIndicator(
                                  backgroundColor: AppColors.slate200,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primaryBrand,
                                  ),
                                ),
                              ),
                            ),

                            AppSpacing.vSpaceMd,

                            // Trust Badge
                            const AppBadge.trust(
                              label: 'Certified Healthcare Platform',
                              icon: Icon(
                                Icons.verified_user_rounded,
                                size: 14,
                                color: AppColors.brandEmeraldDark,
                              ),
                            ),
                          ],
                        ),
                      ),

                      AppSpacing.vSpaceLg,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
