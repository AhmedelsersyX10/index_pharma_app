import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:index_pharma/core/di/service_locator.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/features/auth/domain/services/permission_service.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_state.dart';
import 'package:index_pharma/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await initializeDateFormatting('ar', null);
  await initializeDateFormatting('en', null);
  await setupServiceLocator();
  await getIt.allReady();

  // Restore persisted locale from StorageService on startup
  Locale startLocale = const Locale('ar');
  if (getIt.isRegistered<StorageService>()) {
    final savedCode = getIt<StorageService>().locale;
    if (savedCode != null && (savedCode == 'en' || savedCode == 'ar')) {
      startLocale = Locale(savedCode);
    }
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: startLocale,
      child: const IndexPharmaApp(),
    ),
  );
}

class IndexPharmaApp extends StatelessWidget {
  const IndexPharmaApp({
    super.key,
    this.appRouter,
    this.authCubit,
    this.cartCubit,
    this.themeCubit,
    this.storageService,
    this.permissionService,
  });

  final AppRouter? appRouter;
  final AuthCubit? authCubit;
  final CartCubit? cartCubit;
  final ThemeCubit? themeCubit;
  final StorageService? storageService;
  final PermissionService? permissionService;

  @override
  Widget build(BuildContext context) {
    final router = appRouter ??
        (getIt.isRegistered<AppRouter>()
            ? getIt<AppRouter>()
            : AppRouter());

    final resolvedStorageService = storageService ??
        (getIt.isRegistered<StorageService>() ? getIt<StorageService>() : null);
    final resolvedAuthCubit = authCubit ??
        (getIt.isRegistered<AuthCubit>() ? getIt<AuthCubit>() : null);
    final resolvedCartCubit = cartCubit ??
        (getIt.isRegistered<CartCubit>() ? getIt<CartCubit>() : null);
    final resolvedThemeCubit = themeCubit ??
        (getIt.isRegistered<ThemeCubit>()
            ? getIt<ThemeCubit>()
            : (resolvedStorageService != null
                ? ThemeCubit(storageService: resolvedStorageService)
                : null));
    final resolvedPermissionService = permissionService ??
        (getIt.isRegistered<PermissionService>() ? getIt<PermissionService>() : null);

    final Widget app = resolvedThemeCubit != null
        ? BlocBuilder<ThemeCubit, ThemeMode>(
            bloc: resolvedThemeCubit,
            builder: (context, themeMode) => MaterialApp.router(
              onGenerateTitle: (context) => AppLocaleKeys.appTitle.tr(),
              debugShowCheckedModeBanner: false,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              routerConfig: router.router,
            ),
          )
        : MaterialApp.router(
            onGenerateTitle: (context) => AppLocaleKeys.appTitle.tr(),
            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: router.router,
          );

    Widget wrapped = app;

    final blocProviders = [
      if (resolvedAuthCubit != null)
        BlocProvider<AuthCubit>.value(value: resolvedAuthCubit),
      if (resolvedCartCubit != null)
        BlocProvider<CartCubit>.value(value: resolvedCartCubit),
      if (resolvedThemeCubit != null)
        BlocProvider<ThemeCubit>.value(value: resolvedThemeCubit),
    ];
    if (blocProviders.isNotEmpty) {
      wrapped = MultiBlocProvider(
        providers: blocProviders,
        child: wrapped,
      );
    }

    final repoProviders = [
      if (resolvedStorageService != null)
        RepositoryProvider<StorageService>.value(value: resolvedStorageService),
      if (resolvedPermissionService != null)
        RepositoryProvider<PermissionService>.value(value: resolvedPermissionService),
    ];
    if (repoProviders.isNotEmpty) {
      wrapped = MultiRepositoryProvider(
        providers: repoProviders,
        child: wrapped,
      );
    }

    if (resolvedPermissionService == null && resolvedAuthCubit != null) {
      wrapped = BlocBuilder<AuthCubit, AuthState>(
        bloc: resolvedAuthCubit,
        builder: (context, authState) {
          final user = authState is AuthAuthenticated ? authState.user : null;
          return RepositoryProvider<PermissionService>.value(
            value: PermissionService(user),
            child: wrapped,
          );
        },
      );
    }

    return wrapped;
  }
}

