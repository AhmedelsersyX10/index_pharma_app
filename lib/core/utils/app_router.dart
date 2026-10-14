import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/features/onbording/presentation/view/onboarding_view.dart';
import 'package:index_pharma/features/splash/presentation/view/splash_view.dart';

class AppRouter {
  AppRouter({this.refreshListenable});

  final Listenable? refreshListenable;

  static const kSplashView = '/';
  static const kOnboardingView = '/onboardingView';

  late final GoRouter router = GoRouter(
    refreshListenable: refreshListenable,
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) {
          return const SplashView();
        },
      ),
      GoRoute(
        path: kOnboardingView,
        builder: (context, state) {
          return const OnboardingView();
        },
      ),
    ],
  );
}
