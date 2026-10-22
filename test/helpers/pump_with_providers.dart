import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:index_pharma/core/di/service_locator.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/features/auth/domain/entities/user.dart';
import 'package:index_pharma/features/auth/domain/repositories/auth_repository.dart';
import 'package:index_pharma/features/auth/domain/services/permission_service.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:index_pharma/features/cart/domain/entities/cart_item.dart';
import 'package:index_pharma/features/cart/domain/repositories/cart_repository.dart';
import 'package:index_pharma/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:index_pharma/features/categories/domain/entities/category.dart';
import 'package:index_pharma/features/categories/domain/repositories/categories_repository.dart';
import 'package:index_pharma/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:index_pharma/features/checkout/data/models/order_request_model.dart';
import 'package:index_pharma/features/checkout/domain/entities/order.dart';
import 'package:index_pharma/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:index_pharma/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:index_pharma/features/choose_branches/domain/entities/branch_entity.dart';
import 'package:index_pharma/features/choose_branches/domain/repositories/branch_repository.dart';
import 'package:index_pharma/features/choose_branches/presentation/cubit/branch_cubit.dart';
import 'package:index_pharma/features/orders/domain/entities/my_orders_page.dart';
import 'package:index_pharma/features/orders/domain/repositories/orders_repository.dart';
import 'package:index_pharma/features/orders/domain/usecases/get_my_orders_use_case.dart';
import 'package:index_pharma/features/orders/presentation/cubit/my_orders_cubit.dart';
import 'package:index_pharma/features/prescriptions/domain/entities/prescription_entity.dart';
import 'package:index_pharma/features/prescriptions/domain/entities/prescription_upload_result.dart';
import 'package:index_pharma/features/prescriptions/domain/repositories/prescriptions_repository.dart';
import 'package:index_pharma/features/prescriptions/presentation/cubit/prescription_cubit.dart';
import 'package:index_pharma/features/products/domain/entities/product.dart';
import 'package:index_pharma/features/products/domain/entities/products_page.dart';
import 'package:index_pharma/features/products/domain/repositories/products_repository.dart';
import 'package:index_pharma/features/products/presentation/cubit/product_details_cubit.dart';
import 'package:index_pharma/features/products/presentation/cubit/products_cubit.dart';
import 'package:index_pharma/features/settings/domain/entities/public_settings.dart';
import 'package:index_pharma/features/settings/domain/repositories/settings_repository.dart';
import 'package:index_pharma/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> testArTranslations = {};
Map<String, dynamic> testEnTranslations = {};

class SynchronousDiskAssetLoader extends AssetLoader {
  const SynchronousDiskAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) {
    if (locale.languageCode == 'en') {
      return Future.value(testEnTranslations);
    }
    return Future.value(testArTranslations);
  }
}

Future<void> initTestEnvironment() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  await initializeDateFormatting('ar', null);
  await initializeDateFormatting('en', null);

  final arFile = File('assets/translations/ar.json');
  final enFile = File('assets/translations/en.json');
  if (arFile.existsSync()) {
    testArTranslations =
        jsonDecode(await arFile.readAsString()) as Map<String, dynamic>;
  }
  if (enFile.existsSync()) {
    testEnTranslations =
        jsonDecode(await enFile.readAsString()) as Map<String, dynamic>;
  }

  await EasyLocalization.ensureInitialized();
}

class FakeTestStorageService implements StorageService {
  FakeTestStorageService({
    this.onboardingSeen = true,
    this.locale = 'ar',
    this.selectedBranchId = 'branch-1',
  });

  @override
  bool onboardingSeen;

  @override
  String? locale;

  @override
  String? selectedBranchId;

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

  @override
  String? themeMode;

  @override
  Future<bool> setThemeMode(String mode) async {
    themeMode = mode;
    return true;
  }
}

class FakeTestAuthRepository implements AuthRepository {
  @override
  Future<ApiResult<UserEntity>> getMe() async =>
      const Err(Unauthorized(serverMessage: 'Guest'));

  @override
  Future<ApiResult<UserEntity>> login({
    required String email,
    required String password,
  }) async =>
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
  }) async =>
      throw UnimplementedError();

  @override
  Future<ApiResult<UserEntity>> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async =>
      throw UnimplementedError();
}

class FakeTestCartRepository implements CartRepository {
  final Map<String, List<CartItem>> _storage = {};
  String? _activeBranchId;

  @override
  Future<void> clearCart(String branchId) async {
    _storage.remove(branchId);
    if (_activeBranchId == branchId) _activeBranchId = null;
  }

  @override
  Future<String?> getActiveCartBranchId() async => _activeBranchId;

  @override
  Future<List<CartItem>> getCartItems(String branchId) async =>
      _storage[branchId] ?? [];

  @override
  Future<void> saveCartItems(String branchId, List<CartItem> items) async {
    _storage[branchId] = List<CartItem>.from(items);
    _activeBranchId = branchId;
  }

  @override
  Future<void> setActiveCartBranchId(String? branchId) async {
    _activeBranchId = branchId;
  }
}

class FakeTestBranchRepository implements BranchRepository {
  @override
  Future<ApiResult<List<BranchEntity>>> getBranches() async => const Success([
        BranchEntity(
          id: 'branch-1',
          name: 'فرع مدينة نصر',
          address: 'شارع عباس العقاد',
        ),
      ]);
}

class FakeTestProductsRepository implements ProductsRepository {
  @override
  Future<ApiResult<ProductsPage>> getProducts({
    required String branchId,
    int page = 1,
    int limit = 20,
    String? keyword,
    String? category,
  }) async =>
      const Success(
        ProductsPage(
          total: 0,
          totalPages: 1,
          page: 1,
          limit: 20,
          products: [],
        ),
      );

  @override
  Future<ApiResult<Product>> getProductDetails({
    required String productId,
    required String branchId,
  }) async =>
      throw UnimplementedError();
}

class FakeTestCategoriesRepository implements CategoriesRepository {
  @override
  Future<ApiResult<List<Category>>> getCategories() async =>
      const Success([]);
}

class FakeTestSettingsRepository implements SettingsRepository {
  @override
  Future<ApiResult<PublicSettings>> getPublicSettings() async => const Success(
        PublicSettings(
          pharmacyName: 'إندكس فارما',
          homeHeroTitle: 'صيدليتك الموثوقة',
          homeHeroDesc: 'أدوية موثوقة',
        ),
      );
}

class FakeTestOrdersRepository implements OrdersRepository {
  @override
  Future<ApiResult<MyOrdersPage>> getMyOrders({
    int page = 1,
    int limit = 20,
  }) async =>
      const Success(
        MyOrdersPage(
          orders: [],
          page: 1,
          limit: 20,
          total: 0,
          totalPages: 1,
        ),
      );
}

class FakeTestCheckoutRepository implements CheckoutRepository {
  @override
  Future<ApiResult<Order>> createOrder(OrderRequestModel request) async =>
      throw UnimplementedError();
}

class FakeTestPrescriptionsRepository implements PrescriptionsRepository {
  @override
  Future<ApiResult<List<PrescriptionEntity>>> getMyPrescriptions() async =>
      const Success([]);

  @override
  Future<ApiResult<PrescriptionUploadResult>> uploadPrescriptionImage({
    required String filePath,
    required String fileName,
  }) async =>
      throw UnimplementedError();

  @override
  Future<ApiResult<PrescriptionEntity>> submitPrescription({
    required String imageUrl,
    String? notes,
  }) async =>
      throw UnimplementedError();
}

/// Registers standard mock factory dependencies in GetIt for router navigation tests.
void registerDefaultTestFactories({
  StorageService? storageService,
  BranchRepository? branchRepo,
  SettingsRepository? settingsRepo,
  CategoriesRepository? categoriesRepo,
  ProductsRepository? productsRepo,
  OrdersRepository? ordersRepo,
  CheckoutRepository? checkoutRepo,
  PrescriptionsRepository? prescriptionsRepo,
}) {
  final storage = storageService ?? FakeTestStorageService();
  final bRepo = branchRepo ?? FakeTestBranchRepository();
  final sRepo = settingsRepo ?? FakeTestSettingsRepository();
  final cRepo = categoriesRepo ?? FakeTestCategoriesRepository();
  final pRepo = productsRepo ?? FakeTestProductsRepository();
  final oRepo = ordersRepo ?? FakeTestOrdersRepository();
  final chRepo = checkoutRepo ?? FakeTestCheckoutRepository();
  final prRepo = prescriptionsRepo ?? FakeTestPrescriptionsRepository();

  if (!getIt.isRegistered<StorageService>()) {
    getIt.registerSingleton<StorageService>(storage);
  }

  if (!getIt.isRegistered<BranchCubit>()) {
    getIt.registerFactory<BranchCubit>(
      () => BranchCubit(branchRepository: bRepo, storageService: storage),
    );
  }

  if (!getIt.isRegistered<SettingsCubit>()) {
    getIt.registerFactory<SettingsCubit>(
      () => SettingsCubit(settingsRepository: sRepo),
    );
  }

  if (!getIt.isRegistered<CategoriesCubit>()) {
    getIt.registerFactory<CategoriesCubit>(
      () => CategoriesCubit(categoriesRepository: cRepo),
    );
  }

  if (!getIt.isRegistered<ProductsCubit>()) {
    getIt.registerFactory<ProductsCubit>(
      () => ProductsCubit(
        productsRepository: pRepo,
        storageService: storage,
      ),
    );
  }

  if (!getIt.isRegistered<ProductDetailsCubit>()) {
    getIt.registerFactory<ProductDetailsCubit>(
      () => ProductDetailsCubit(
        productsRepository: pRepo,
        storageService: storage,
      ),
    );
  }

  if (!getIt.isRegistered<GetMyOrdersUseCase>()) {
    getIt.registerFactory<GetMyOrdersUseCase>(
      () => GetMyOrdersUseCase(repository: oRepo),
    );
  }

  if (!getIt.isRegistered<MyOrdersCubit>()) {
    getIt.registerFactory<MyOrdersCubit>(
      () => MyOrdersCubit(
        getMyOrdersUseCase: GetMyOrdersUseCase(repository: oRepo),
      ),
    );
  }

  if (!getIt.isRegistered<CheckoutCubit>()) {
    getIt.registerFactory<CheckoutCubit>(
      () {
        final cart = getIt.isRegistered<CartCubit>()
            ? getIt<CartCubit>()
            : CartCubit(
                cartRepository: FakeTestCartRepository(),
                storageService: storage,
              );
        return CheckoutCubit(
          checkoutRepository: chRepo,
          cartCubit: cart,
        );
      },
    );
  }

  if (!getIt.isRegistered<PrescriptionCubit>()) {
    getIt.registerFactory<PrescriptionCubit>(
      () => PrescriptionCubit(repository: prRepo),
    );
  }
}

/// Builds an app wrapped with all root providers (matching main.dart).
Widget buildAppWithProviders({
  Widget? child,
  RouterConfig<Object>? routerConfig,
  AuthCubit? authCubit,
  CartCubit? cartCubit,
  ThemeCubit? themeCubit,
  StorageService? storageService,
  PermissionService? permissionService,
  Locale locale = const Locale('ar'),
}) {
  final effectiveStorage = storageService ??
      (getIt.isRegistered<StorageService>()
          ? getIt<StorageService>()
          : FakeTestStorageService());

  final effectiveAuth = authCubit ??
      (getIt.isRegistered<AuthCubit>()
          ? getIt<AuthCubit>()
          : AuthCubit(authRepository: FakeTestAuthRepository()));

  final effectiveCart = cartCubit ??
      (getIt.isRegistered<CartCubit>()
          ? getIt<CartCubit>()
          : CartCubit(
              cartRepository: FakeTestCartRepository(),
              storageService: effectiveStorage,
            ));

  final effectiveTheme = themeCubit ??
      (getIt.isRegistered<ThemeCubit>()
          ? getIt<ThemeCubit>()
          : ThemeCubit(storageService: effectiveStorage));

  final effectivePermission = permissionService ??
      (getIt.isRegistered<PermissionService>()
          ? getIt<PermissionService>()
          : const PermissionService());

  return EasyLocalization(
    key: UniqueKey(),
    supportedLocales: const [Locale('ar'), Locale('en')],
    path: 'assets/translations',
    fallbackLocale: const Locale('ar'),
    startLocale: locale,
    saveLocale: false,
    useOnlyLangCode: true,
    assetLoader: const SynchronousDiskAssetLoader(),
    child: Builder(
      builder: (context) {
        return MultiRepositoryProvider(
          providers: [
            RepositoryProvider<StorageService>.value(value: effectiveStorage),
            RepositoryProvider<PermissionService>.value(
              value: effectivePermission,
            ),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<AuthCubit>.value(value: effectiveAuth),
              BlocProvider<CartCubit>.value(value: effectiveCart),
              BlocProvider<ThemeCubit>.value(value: effectiveTheme),
            ],
            child: BlocBuilder<ThemeCubit, ThemeMode>(
              bloc: effectiveTheme,
              builder: (context, themeMode) {
                return routerConfig != null
                    ? MaterialApp.router(
                        localizationsDelegates: context.localizationDelegates,
                        supportedLocales: context.supportedLocales,
                        locale: context.locale,
                        theme: AppTheme.lightTheme,
                        darkTheme: AppTheme.darkTheme,
                        themeMode: themeMode,
                        routerConfig: routerConfig,
                      )
                    : MaterialApp(
                        localizationsDelegates: context.localizationDelegates,
                        supportedLocales: context.supportedLocales,
                        locale: context.locale,
                        theme: AppTheme.lightTheme,
                        darkTheme: AppTheme.darkTheme,
                        themeMode: themeMode,
                        home: child,
                      );
              },
            ),
          ),
        );
      },
    ),
  );
}
