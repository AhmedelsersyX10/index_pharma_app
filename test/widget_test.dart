import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/di/service_locator.dart';
import 'package:index_pharma/features/auth/domain/services/permission_service.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:index_pharma/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:index_pharma/features/splash/presentation/view/splash_view.dart';
import 'package:index_pharma/main.dart';

import 'helpers/pump_with_providers.dart';

void main() {
  setUpAll(() async {
    await initTestEnvironment();
  });

  setUp(() {
    getIt.reset();
    registerDefaultTestFactories();
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('IndexPharmaApp smoke test - launches to SplashView',
      (WidgetTester tester) async {
    final storage = FakeTestStorageService();
    final authRepo = FakeTestAuthRepository();
    final authCubit = AuthCubit(authRepository: authRepo);
    final cartCubit = CartCubit(
      cartRepository: FakeTestCartRepository(),
      storageService: storage,
    );

    addTearDown(() async {
      await authCubit.close();
      await cartCubit.close();
    });

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('ar'), Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('ar'),
        startLocale: const Locale('ar'),
        useOnlyLangCode: true,
        assetLoader: const SynchronousDiskAssetLoader(),
        child: IndexPharmaApp(
          storageService: storage,
          authCubit: authCubit,
          cartCubit: cartCubit,
          permissionService: const PermissionService(),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(IndexPharmaApp), findsOneWidget);
    expect(find.byType(SplashView), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
  });
}
