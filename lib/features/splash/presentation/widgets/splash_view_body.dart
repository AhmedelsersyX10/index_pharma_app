import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/features/auth/domain/entities/user.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_state.dart';
import 'package:index_pharma/features/splash/presentation/widgets/splash_background.dart';
import 'package:index_pharma/features/splash/presentation/widgets/splash_brand_text.dart';
import 'package:index_pharma/features/splash/presentation/widgets/splash_footer.dart';
import 'package:index_pharma/features/splash/presentation/widgets/splash_logo.dart';

class SplashViewBody extends StatefulWidget {
  const SplashViewBody({
    super.key,
    this.authCubit,
    this.storageService,
    this.minSplashDuration = const Duration(milliseconds: 2200),
  });

  final AuthCubit? authCubit;
  final StorageService? storageService;
  final Duration minSplashDuration;

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
    _bootstrapAndNavigate();
  }

  Future<void> _bootstrapAndNavigate() async {
    final timerFuture = Future.delayed(widget.minSplashDuration);

    // 1. Resolve StorageService
    final storage = widget.storageService ?? context.read<StorageService>();

    // 2. Resolve AuthCubit and restoreSession()
    final auth = widget.authCubit ?? context.read<AuthCubit>();
    await auth.restoreSession();

    // Wait for minimum splash animation duration
    await timerFuture;

    if (!mounted) return;

    final bool onboardingSeen = storage.onboardingSeen;
    if (!onboardingSeen) {
      final bool hasSelectedLocale = storage.locale != null;
      if (!hasSelectedLocale) {
        context.go(AppRouter.kLanguageSelectionView);
        return;
      }
      context.go(AppRouter.kOnboardingView);
      return;
    }

    final authState = auth.state;
    switch (authState) {
      case AuthAuthenticated(:final user):
        if (user.role == UserRole.pharmacist ||
            user.role == UserRole.admin ||
            user.role == UserRole.superadmin) {
          context.go(AppRouter.kStaffDashboardView);
        } else {
          context.go(AppRouter.kStoreView);
        }
      case AuthGuest():
      case AuthInitial():
      case AuthLoading():
      case AuthFailure():
        context.go(AppRouter.kStoreView);
    }
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
            // Ambient clinical background illumination & pulse
            SplashBackground(pulseGlow: _pulseGlow),

            // Main center content
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spaceXl,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 3),

                      // Animated Logo with Ambient Elevation
                      SplashLogo(
                        logoFade: _logoFade,
                        logoScale: _logoScale,
                      ),

                      AppSpacing.vSpaceLg,

                      // Animated Brand Typography & Slogan
                      SplashBrandText(
                        textFade: _textFade,
                        textSlide: _textSlide,
                      ),

                      const Spacer(flex: 3),

                      // Animated Footer (Loading indicator & Trust Badge)
                      SplashFooter(footerFade: _footerFade),

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
