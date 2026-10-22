import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/di/service_locator.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/features/auth/domain/entities/user.dart';
import 'package:index_pharma/features/auth/domain/repositories/auth_repository.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:index_pharma/features/cart/domain/entities/cart_item.dart';
import 'package:index_pharma/features/cart/domain/repositories/cart_repository.dart';
import 'package:index_pharma/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:index_pharma/features/categories/domain/entities/category.dart';
import 'package:index_pharma/features/categories/domain/repositories/categories_repository.dart';
import 'package:index_pharma/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:index_pharma/features/choose_branches/domain/entities/branch_entity.dart';
import 'package:index_pharma/features/choose_branches/domain/repositories/branch_repository.dart';
import 'package:index_pharma/features/choose_branches/presentation/cubit/branch_cubit.dart';
import 'package:index_pharma/features/products/domain/entities/product.dart';
import 'package:index_pharma/features/products/domain/entities/products_page.dart';
import 'package:index_pharma/features/products/domain/repositories/products_repository.dart';
import 'package:index_pharma/features/products/presentation/cubit/products_cubit.dart';
import 'package:index_pharma/features/products/presentation/screens/products_page.dart' hide ProductsPage;
import 'package:index_pharma/features/settings/domain/entities/public_settings.dart';
import 'package:index_pharma/features/settings/domain/repositories/settings_repository.dart';
import 'package:index_pharma/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

late final Map<String, dynamic> _arTranslations;
late final Map<String, dynamic> _enTranslations;

class SynchronousDiskAssetLoader extends AssetLoader {
  const SynchronousDiskAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) {
    if (locale.languageCode == 'en') {
      return Future.value(_enTranslations);
    }
    return Future.value(_arTranslations);
  }
}

class FakeStorageService implements StorageService {
  FakeStorageService({this.onboardingSeen = true, this.locale = 'ar'});

  @override
  bool onboardingSeen;

  @override
  String? locale;

  @override
  String? selectedBranchId = 'b1';

  @override
  Future<bool> clearSelectedBranchId() async {
    selectedBranchId = null;
    return true;
  }

  @override
  Future<bool> setLocale(String locale) async {
    this.locale = locale;
    return true;
  }

  @override
  Future<bool> setOnboardingSeen(bool seen) async {
    onboardingSeen = seen;
    return true;
  }

  @override
  Future<bool> setSelectedBranchId(String branchId) async {
    selectedBranchId = branchId;
    return true;
  }
}

class FakeProductsRepository implements ProductsRepository {
  String? lastBranchId;
  String? lastKeyword;
  String? lastCategory;
  int lastPage = 1;

  @override
  Future<ApiResult<ProductsPage>> getProducts({
    required String branchId,
    int page = 1,
    int limit = 20,
    String? keyword,
    String? category,
  }) async {
    lastBranchId = branchId;
    lastKeyword = keyword;
    lastCategory = category;
    lastPage = page;

    return const Success(ProductsPage(products: [], total: 0, page: 1, limit: 20, totalPages: 0));
  }

  @override
  Future<ApiResult<Product>> getProductDetails({
    required String productId,
    required String branchId,
  }) async {
    return const Err(NotFound(serverMessage: 'Not found'));
  }
}

class FakeCategoriesRepository implements CategoriesRepository {
  @override
  Future<ApiResult<List<Category>>> getCategories() async {
    return const Success([
      Category(id: 'cat-1', name: 'أدوية القلب والضغط'),
      Category(id: 'cat-2', name: 'المضادات الحيوية'),
    ]);
  }
}

class FakeBranchRepository implements BranchRepository {
  @override
  Future<ApiResult<List<BranchEntity>>> getBranches() async {
    return const Success([
      BranchEntity(id: 'b1', name: 'فرع مدينة نصر', address: 'شارع الطيران', phone: '01000000000'),
    ]);
  }
}

class FakeAuthRepository implements AuthRepository {
  @override
  Future<ApiResult<UserEntity>> getMe() async => const Err(Unauthorized(serverMessage: 'Guest'));

  @override
  Future<ApiResult<UserEntity>> login({required String email, required String password}) async =>
      throw UnimplementedError();

  @override
  Future<ApiResult<void>> logout() async => const Success(null);

  @override
  Future<ApiResult<UserEntity>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? address,
  }) async => throw UnimplementedError();

  @override
  Future<ApiResult<UserEntity>> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async => throw UnimplementedError();
}

class FakeCartRepository implements CartRepository {
  @override
  Future<void> clearCart(String branchId) async {}

  @override
  Future<String?> getActiveCartBranchId() async => 'b1';

  @override
  Future<List<CartItem>> getCartItems(String branchId) async => [];

  @override
  Future<void> saveCartItems(String branchId, List<CartItem> items) async {}

  @override
  Future<void> setActiveCartBranchId(String? branchId) async {}
}

class FakeSettingsRepository implements SettingsRepository {
  @override
  Future<ApiResult<PublicSettings>> getPublicSettings() async {
    return const Success(
      PublicSettings(
        pharmacyName: 'إندكس فارما',
        homeHeroTitle: 'صيدليتك الموثوقة',
        homeHeroDesc: 'أدوية موثوقة',
      ),
    );
  }
}

Widget createRouterTestApp({required RouterConfig<Object> routerConfig}) {
  return EasyLocalization(
    supportedLocales: const [Locale('ar'), Locale('en')],
    path: 'assets/translations',
    fallbackLocale: const Locale('ar'),
    startLocale: const Locale('ar'),
    saveLocale: false,
    useOnlyLangCode: true,
    assetLoader: const SynchronousDiskAssetLoader(),
    child: Builder(
      builder: (context) {
        return MaterialApp.router(
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: AppTheme.lightTheme,
          routerConfig: routerConfig,
        );
      },
    ),
  );
}

void main() {
  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    final arFile = File('assets/translations/ar.json');
    final enFile = File('assets/translations/en.json');
    _arTranslations = jsonDecode(await arFile.readAsString()) as Map<String, dynamic>;
    _enTranslations = jsonDecode(await enFile.readAsString()) as Map<String, dynamic>;
    await EasyLocalization.ensureInitialized();
  });

  group('BrowseScreen Navigation & Query Parameter Tests', () {
    late FakeProductsRepository productsRepo;
    late FakeCategoriesRepository categoriesRepo;
    late FakeBranchRepository branchRepo;
    late FakeAuthRepository authRepo;
    late FakeCartRepository cartRepo;
    late FakeSettingsRepository settingsRepo;
    late FakeStorageService storageService;

    late BranchCubit branchCubit;
    late SettingsCubit settingsCubit;
    late CategoriesCubit categoriesCubit;
    late ProductsCubit productsCubit;
    late CartCubit cartCubit;
    late AuthCubit authCubit;

    setUp(() {
      getIt.reset();

      productsRepo = FakeProductsRepository();
      categoriesRepo = FakeCategoriesRepository();
      branchRepo = FakeBranchRepository();
      authRepo = FakeAuthRepository();
      cartRepo = FakeCartRepository();
      settingsRepo = FakeSettingsRepository();
      storageService = FakeStorageService();

      branchCubit = BranchCubit(branchRepository: branchRepo, storageService: storageService);
      settingsCubit = SettingsCubit(settingsRepository: settingsRepo);
      categoriesCubit = CategoriesCubit(categoriesRepository: categoriesRepo);
      productsCubit = ProductsCubit(
        productsRepository: productsRepo,
        storageService: storageService,
      );
      cartCubit = CartCubit(cartRepository: cartRepo, storageService: storageService);
      authCubit = AuthCubit(authRepository: authRepo);

      getIt.registerSingleton<StorageService>(storageService);
      getIt.registerSingleton<BranchCubit>(branchCubit);
      getIt.registerSingleton<SettingsCubit>(settingsCubit);
      getIt.registerSingleton<CategoriesCubit>(categoriesCubit);
      getIt.registerSingleton<ProductsCubit>(productsCubit);
      getIt.registerSingleton<CartCubit>(cartCubit);
      getIt.registerSingleton<AuthCubit>(authCubit);
    });

    tearDown(() {
      getIt.reset();
    });

    testWidgets('navigating to /browse renders BrowseScreen without filters', (tester) async {
      final appRouter = AppRouter(
        authCubit: authCubit,
        storageService: storageService,
        initialLocation: AppRouter.browsePath(),
      );
      await tester.pumpWidget(createRouterTestApp(routerConfig: appRouter.router));
      await tester.pumpAndSettle();

      expect(find.byType(ProductsPage), findsOneWidget);
      expect(productsRepo.lastCategory, isNull);
      expect(productsRepo.lastKeyword, isNull);
    });

    testWidgets('navigating to /browse with categoryId passes category filter to cubit', (
      tester,
    ) async {
      final appRouter = AppRouter(
        authCubit: authCubit,
        storageService: storageService,
        initialLocation: AppRouter.browsePath(categoryId: 'cat-2'),
      );
      await tester.pumpWidget(createRouterTestApp(routerConfig: appRouter.router));
      await tester.pumpAndSettle();

      expect(find.byType(ProductsPage), findsOneWidget);
      expect(productsRepo.lastCategory, 'cat-2');
    });

    testWidgets('navigating to /browse with q passes keyword to cubit and initializes search bar', (
      tester,
    ) async {
      final appRouter = AppRouter(
        authCubit: authCubit,
        storageService: storageService,
        initialLocation: AppRouter.browsePath(q: 'panadol'),
      );
      await tester.pumpWidget(createRouterTestApp(routerConfig: appRouter.router));
      await tester.pumpAndSettle();

      expect(find.byType(ProductsPage), findsOneWidget);
      expect(productsRepo.lastKeyword, 'panadol');
      expect(find.widgetWithText(TextField, 'panadol'), findsOneWidget);
    });

    testWidgets('navigating to /browse with categoryId and q passes both to cubit', (tester) async {
      final appRouter = AppRouter(
        authCubit: authCubit,
        storageService: storageService,
        initialLocation: AppRouter.browsePath(categoryId: 'cat-1', q: 'aspirin'),
      );
      await tester.pumpWidget(createRouterTestApp(routerConfig: appRouter.router));
      await tester.pumpAndSettle();

      expect(find.byType(ProductsPage), findsOneWidget);
      expect(productsRepo.lastCategory, 'cat-1');
      expect(productsRepo.lastKeyword, 'aspirin');
    });
  });
}
