import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/di/service_locator.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await setupServiceLocator();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      child: const IndexPharmaApp(),
    ),
  );
}

class IndexPharmaApp extends StatelessWidget {
  const IndexPharmaApp({
    super.key,
    this.appRouter,
  });

  final AppRouter? appRouter;

  @override
  Widget build(BuildContext context) {
    final router = appRouter ??
        (getIt.isRegistered<AppRouter>()
            ? getIt<AppRouter>()
            : AppRouter());

    return MaterialApp.router(
      title: AppLocaleKeys.appTitle.tr(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router.router,
    );
  }
}
