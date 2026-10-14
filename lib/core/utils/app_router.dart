import 'package:go_router/go_router.dart';
import 'package:index_pharma/features/onbording/presentation/view/onboarding_view.dart';
import 'package:index_pharma/features/splash/presentation/view/splash_view.dart';

abstract class AppRouter {
  static const kSplashView = '/';
  static const kOnboardingView = '/onboardingView';

  static final GoRouter router = GoRouter(
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
