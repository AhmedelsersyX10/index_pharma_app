import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/utils/app_router.dart';

void main() {
  group('AppRouter', () {
    test('exposes route constants unchanged', () {
      expect(AppRouter.kSplashView, equals('/'));
      expect(AppRouter.kOnboardingView, equals('/onboardingView'));
    });

    test('creates GoRouter with existing routes (splash and onboarding)', () {
      final appRouter = AppRouter();
      final routes = appRouter.router.configuration.routes;

      expect(routes.length, equals(2));
      final routePaths = routes.whereType<GoRoute>().map((r) => r.path).toList();
      expect(routePaths, contains('/'));
      expect(routePaths, contains(AppRouter.kOnboardingView));
    });

    test('accepts optional refreshListenable without error and listens to it', () {
      final notifier = ValueNotifier<int>(0);
      final appRouter = AppRouter(refreshListenable: notifier);

      expect(appRouter.refreshListenable, equals(notifier));
      expect(appRouter.router, isNotNull);

      // Notifying listeners should not throw
      expect(() => notifier.value++, returnsNormally);
      notifier.dispose();
    });
  });
}
