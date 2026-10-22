import 'dart:typed_data';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:index_pharma/core/di/service_locator.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/network/api_client.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/core/widgets/app_buttons.dart';
import 'package:index_pharma/features/account/presentation/screens/account_screen.dart';
import 'package:index_pharma/features/account/presentation/widgets/account_guest_view.dart';
import 'package:index_pharma/features/account/presentation/widgets/account_profile_card.dart';
import 'package:index_pharma/features/orders/presentation/cubit/my_orders_cubit.dart';

import '../../../helpers/pump_with_providers.dart';
import 'package:index_pharma/features/auth/domain/entities/user.dart';
import 'package:index_pharma/features/auth/domain/repositories/auth_repository.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_state.dart';
import 'package:index_pharma/features/auth/presentation/screens/login_screen.dart';
import 'package:index_pharma/features/auth/presentation/screens/register_screen.dart';
import 'package:index_pharma/features/cart/domain/entities/cart_item.dart';
import 'package:index_pharma/features/cart/domain/repositories/cart_repository.dart';
import 'package:index_pharma/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:index_pharma/features/categories/domain/entities/category.dart';
import 'package:index_pharma/features/categories/domain/repositories/categories_repository.dart';
import 'package:index_pharma/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:index_pharma/features/choose_branches/domain/entities/branch_entity.dart';
import 'package:index_pharma/features/choose_branches/domain/repositories/branch_repository.dart';
import 'package:index_pharma/features/choose_branches/presentation/cubit/branch_cubit.dart';
import 'package:index_pharma/features/home/presentation/screens/home_screen.dart';
import 'package:index_pharma/features/orders/domain/entities/my_orders_page.dart';
import 'package:index_pharma/features/orders/domain/repositories/orders_repository.dart';
import 'package:index_pharma/features/orders/domain/usecases/get_my_orders_use_case.dart';
import 'package:index_pharma/features/orders/presentation/screens/my_orders_screen.dart';
import 'package:index_pharma/features/products/domain/entities/product.dart';
import 'package:index_pharma/features/products/domain/entities/products_page.dart';
import 'package:index_pharma/features/products/domain/repositories/products_repository.dart';
import 'package:index_pharma/features/products/presentation/cubit/products_cubit.dart';
import 'package:index_pharma/features/settings/domain/entities/public_settings.dart';
import 'package:index_pharma/features/settings/domain/repositories/settings_repository.dart';
import 'package:index_pharma/features/settings/presentation/cubit/settings_cubit.dart';

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

class FakeAuthRepository implements AuthRepository {
  ApiResult<UserEntity>? getMeResult;
  ApiResult<UserEntity>? loginResult;
  ApiResult<UserEntity>? registerResult;

  int loginCallCount = 0;
  int registerCallCount = 0;

  @override
  Future<ApiResult<UserEntity>> getMe() async {
    return getMeResult ?? const Err(Unauthorized());
  }

  @override
  Future<ApiResult<UserEntity>> login({
    required String email,
    required String password,
  }) async {
    loginCallCount++;
    return loginResult ??
        const Success(
          UserEntity(
            id: 'c1',
            name: 'أحمد العميل',
            email: 'customer@example.com',
            role: UserRole.customer,
          ),
        );
  }

  @override
  Future<ApiResult<UserEntity>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? address,
  }) async {
    registerCallCount++;
    return registerResult ??
        const Success(
          UserEntity(
            id: 'c2',
            name: 'عميل جديد',
            email: 'new@example.com',
            role: UserRole.customer,
          ),
        );
  }

  @override
  Future<ApiResult<void>> logout() async => const Success(null);

  @override
  Future<ApiResult<UserEntity>> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async =>
      const Err(Unauthorized());
}

class FakeBranchRepository implements BranchRepository {
  @override
  Future<ApiResult<List<BranchEntity>>> getBranches() async {
    return const Success([
      BranchEntity(
        id: 'b1',
        name: 'فرع مدينة نصر',
        address: 'شارع عباس العقاد',
        phone: '01012345678',
      ),
    ]);
  }
}

class FakeSettingsRepository implements SettingsRepository {
  @override
  Future<ApiResult<PublicSettings>> getPublicSettings() async {
    return const Success(
      PublicSettings(
        pharmacyName: 'إندكس فارما',
        homeHeroTitle: 'صيدليتك الموثوقة',
        homeHeroDesc: 'أدوية أصلية',
      ),
    );
  }
}

class FakeCategoriesRepository implements CategoriesRepository {
  @override
  Future<ApiResult<List<Category>>> getCategories() async {
    return const Success([
      Category(id: 'c1', name: 'المسكنات'),
    ]);
  }
}

class FakeProductsRepository implements ProductsRepository {
  @override
  Future<ApiResult<ProductsPage>> getProducts({
    required String branchId,
    int page = 1,
    int limit = 20,
    String? keyword,
    String? category,
  }) async {
    return const Success(
      ProductsPage(
        products: [],
        total: 0,
        totalPages: 0,
        page: 1,
        limit: 20,
      ),
    );
  }

  @override
  Future<ApiResult<Product>> getProductDetails({
    required String productId,
    String? branchId,
  }) async {
    return const Err(NotFound(serverMessage: 'Not found'));
  }
}

class FakeCartRepository implements CartRepository {
  final Map<String, List<CartItem>> storage = {};
  String? activeBranchId;

  @override
  Future<List<CartItem>> getCartItems(String branchId) async =>
      storage[branchId] ?? [];

  @override
  Future<void> saveCartItems(String branchId, List<CartItem> items) async {
    storage[branchId] = List<CartItem>.from(items);
    activeBranchId = branchId;
  }

  @override
  Future<void> clearCart(String branchId) async {
    storage.remove(branchId);
    if (activeBranchId == branchId) activeBranchId = null;
  }

  @override
  Future<String?> getActiveCartBranchId() async => activeBranchId;

  @override
  Future<void> setActiveCartBranchId(String? branchId) async {
    activeBranchId = branchId;
  }
}

class FakeOrdersRepository implements OrdersRepository {
  @override
  Future<ApiResult<MyOrdersPage>> getMyOrders({
    int page = 1,
    int limit = 20,
  }) async {
    return const Success(
      MyOrdersPage(
        orders: [],
        total: 0,
        totalPages: 0,
        page: 1,
        limit: 20,
      ),
    );
  }
}

class FakeHttpClientAdapter implements HttpClientAdapter {
  FakeHttpClientAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

Widget createTestApp(RouterConfig<Object> routerConfig) {
  return buildAppWithProviders(
    routerConfig: routerConfig,
  );
}

void main() {
  setUpAll(() async {
    await initTestEnvironment();
    _arTranslations = testArTranslations;
    _enTranslations = testEnTranslations;
  });

  group('Login & Registration Navigation Flow Tests', () {
    late FakeAuthRepository authRepo;
    late FakeStorageService storageService;
    late AuthCubit authCubit;
    late FakeBranchRepository branchRepo;
    late FakeSettingsRepository settingsRepo;
    late FakeCategoriesRepository categoriesRepo;
    late FakeProductsRepository productsRepo;
    late FakeCartRepository cartRepo;
    late FakeOrdersRepository ordersRepo;

    setUp(() {
      GetIt.instance.reset();

      authRepo = FakeAuthRepository();
      storageService = FakeStorageService(onboardingSeen: true);
      authCubit = AuthCubit(authRepository: authRepo);

      branchRepo = FakeBranchRepository();
      settingsRepo = FakeSettingsRepository();
      categoriesRepo = FakeCategoriesRepository();
      productsRepo = FakeProductsRepository();
      cartRepo = FakeCartRepository();
      ordersRepo = FakeOrdersRepository();

      // Register services needed by screens
      getIt.registerSingleton<StorageService>(storageService);
      getIt.registerSingleton<AuthCubit>(authCubit);

      final cartCubit = CartCubit(
        cartRepository: cartRepo,
        storageService: storageService,
      );
      getIt.registerSingleton<CartCubit>(cartCubit);

      getIt.registerFactory<BranchCubit>(
        () => BranchCubit(
          branchRepository: branchRepo,
          storageService: storageService,
        ),
      );
      getIt.registerFactory<SettingsCubit>(
        () => SettingsCubit(settingsRepository: settingsRepo),
      );
      getIt.registerFactory<CategoriesCubit>(
        () => CategoriesCubit(categoriesRepository: categoriesRepo),
      );
      getIt.registerFactory<ProductsCubit>(
        () => ProductsCubit(
          productsRepository: productsRepo,
          storageService: storageService,
        ),
      );
      getIt.registerFactory<GetMyOrdersUseCase>(
        () => GetMyOrdersUseCase(repository: ordersRepo),
      );
      getIt.registerFactory<MyOrdersCubit>(
        () => MyOrdersCubit(
          getMyOrdersUseCase: GetMyOrdersUseCase(repository: ordersRepo),
        ),
      );
    });

    tearDown(() async {
      await getIt.reset();
    });

    testWidgets(
      'BUG REPRODUCTION: Guest on /store navigates to Account, taps Sign In (context.push /login), logs in -> screen must navigate away and show authenticated Account',
      (tester) async {
        // 1. Initial location: /store as Guest
        final appRouter = AppRouter(
          authCubit: authCubit,
          storageService: storageService,
          initialLocation: AppRouter.kStoreView,
        );

        await tester.pumpWidget(createTestApp(appRouter.router));
        await tester.pumpAndSettle();

        expect(find.byType(HomeScreen), findsOneWidget);

        // 2. Tap Account in CustomerBottomNav (tab index 4)
        final accountTab = find.byIcon(Icons.person_outline_rounded);
        expect(accountTab, findsOneWidget);
        await tester.tap(accountTab);
        await tester.pumpAndSettle();

        // 3. Verify AccountScreen is shown in Guest mode
        expect(find.byType(AccountScreen), findsOneWidget);
        expect(find.byType(AccountGuestView), findsOneWidget);

        // 4. Tap Sign In button (guest_login_button) -> context.push('/login')
        final signInBtn = find.byKey(const ValueKey('guest_login_button'));
        expect(signInBtn, findsOneWidget);
        await tester.tap(signInBtn);
        await tester.pumpAndSettle();

        // 5. Verify LoginScreen is shown
        expect(find.byType(LoginScreen), findsOneWidget);

        // 6. Enter credentials and tap Login
        final emailField = find.byType(TextFormField).at(0);
        final passwordField = find.byType(TextFormField).at(1);
        await tester.enterText(emailField, 'customer@example.com');
        await tester.enterText(passwordField, 'Password123');
        await tester.pumpAndSettle();

        final submitBtn = find.widgetWithText(
          AppButton,
          'تسجيل الدخول',
        );
        expect(submitBtn, findsOneWidget);
        await tester.tap(submitBtn);
        await tester.pumpAndSettle();

        // Assert login was called
        expect(authRepo.loginCallCount, equals(1));

        // 7. ASSERTION THAT PROVES THE BUG:
        // The app must have navigated away from LoginScreen, and AccountScreen
        // must now display the authenticated profile card.
        expect(find.byType(LoginScreen), findsNothing);
        expect(find.byType(AccountProfileCard), findsOneWidget);
      },
    );

    testWidgets(
      'Protected route with ?from=: Guest enters /orders, redirected to login with from=/orders, logs in -> customer returns to /orders',
      (tester) async {
        final appRouter = AppRouter(
          authCubit: authCubit,
          storageService: storageService,
          initialLocation: AppRouter.kOrdersView,
        );

        await tester.pumpWidget(createTestApp(appRouter.router));
        await tester.pumpAndSettle();

        // Protected route guard displays prompt
        expect(find.text(AppLocaleKeys.authLoginRequiredTitle.tr()), findsOneWidget);

        // Tap Sign In in the prompt -> context.go('/login?from=/orders')
        final promptLoginBtn = find.widgetWithText(
          AppButton,
          AppLocaleKeys.authLoginRequiredBtnLogin.tr(),
        );
        expect(promptLoginBtn, findsOneWidget);
        await tester.tap(promptLoginBtn);
        await tester.pumpAndSettle();

        expect(find.byType(LoginScreen), findsOneWidget);

        // Enter credentials and submit
        final emailField = find.byType(TextFormField).at(0);
        final passwordField = find.byType(TextFormField).at(1);
        await tester.enterText(emailField, 'customer@example.com');
        await tester.enterText(passwordField, 'Password123');
        await tester.pumpAndSettle();

        final submitBtn = find.widgetWithText(
          AppButton,
          AppLocaleKeys.authSignInButton.tr(),
        );
        await tester.ensureVisible(submitBtn);
        await tester.tap(submitBtn);
        await tester.pumpAndSettle();

        expect(find.byType(LoginScreen), findsNothing);
        expect(find.byType(MyOrdersScreen), findsOneWidget);
        expect(
          appRouter.router.state.matchedLocation,
          equals(AppRouter.kOrdersView),
        );
      },
    );

    testWidgets(
      'Protected route with ?from=: Staff logs in from protected route -> routes to /staff',
      (tester) async {
        authRepo.loginResult = const Success(
          UserEntity(
            id: 'p1',
            name: 'د. صيدلي',
            email: 'pharmacist@example.com',
            role: UserRole.pharmacist,
          ),
        );

        final appRouter = AppRouter(
          authCubit: authCubit,
          storageService: storageService,
          initialLocation: AppRouter.kOrdersView,
        );

        await tester.pumpWidget(createTestApp(appRouter.router));
        await tester.pumpAndSettle();

        final promptLoginBtn = find.widgetWithText(
          AppButton,
          AppLocaleKeys.authLoginRequiredBtnLogin.tr(),
        );
        expect(promptLoginBtn, findsOneWidget);
        await tester.tap(promptLoginBtn);
        await tester.pumpAndSettle();

        expect(find.byType(LoginScreen), findsOneWidget);

        final emailField = find.byType(TextFormField).at(0);
        final passwordField = find.byType(TextFormField).at(1);
        await tester.enterText(emailField, 'pharmacist@example.com');
        await tester.enterText(passwordField, 'Password123');
        await tester.pumpAndSettle();

        final submitBtn = find.widgetWithText(
          AppButton,
          AppLocaleKeys.authSignInButton.tr(),
        );
        await tester.ensureVisible(submitBtn);
        await tester.tap(submitBtn);
        await tester.pumpAndSettle();

        expect(find.byType(LoginScreen), findsNothing);
        expect(
          appRouter.router.state.matchedLocation,
          equals(AppRouter.kStaffDashboardView),
        );
      },
    );

    testWidgets(
      'Registration flow: Guest on Account taps Register, fills form and submits -> navigates to Account authenticated',
      (tester) async {
        final appRouter = AppRouter(
          authCubit: authCubit,
          storageService: storageService,
          initialLocation: AppRouter.kAccountView,
        );

        await tester.pumpWidget(createTestApp(appRouter.router));
        await tester.pumpAndSettle();

        expect(find.byType(AccountGuestView), findsOneWidget);

        // Tap Register button
        final registerBtn = find.byKey(const ValueKey('guest_register_button'));
        expect(registerBtn, findsOneWidget);
        await tester.ensureVisible(registerBtn);
        await tester.tap(registerBtn);
        await tester.pumpAndSettle();

        expect(find.byType(RegisterScreen), findsOneWidget);

        // Fill registration form: Name, Email, Password (>= 8 chars)
        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.at(0), 'عميل جديد');
        await tester.enterText(textFields.at(1), 'new@example.com');
        await tester.enterText(textFields.at(4), 'ValidPass123');
        await tester.pumpAndSettle();

        // Tap Register submit button
        final submitBtn = find.widgetWithText(
          AppButton,
          AppLocaleKeys.authRegisterButton.tr(),
        );
        expect(submitBtn, findsOneWidget);
        await tester.ensureVisible(submitBtn);
        await tester.tap(submitBtn);
        await tester.pumpAndSettle();

        expect(authRepo.registerCallCount, equals(1));

        // Must have navigated back to Account and display authenticated card
        expect(find.byType(RegisterScreen), findsNothing);
        expect(find.byType(AccountProfileCard), findsOneWidget);
      },
    );

    test(
      'Stray 401 handling: unauthenticated 401 on protected endpoint triggers session expiration, but 401 on login endpoint does not',
      () async {
        final client = ApiClient(
          cookieJar: CookieJar(),
          enableLogging: false,
        );

        final authCubitWithClient = AuthCubit(
          authRepository: authRepo,
          apiClient: client,
        );
        addTearDown(authCubitWithClient.close);

        // Configure client adapter to simulate 401
        client.dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
          return ResponseBody.fromString(
            '{"message": "Unauthorized"}',
            401,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        });

        // 1. Calling /auth/login with 401 - must NOT trigger session expiration
        await expectLater(
          client.dio.post<dynamic>('/auth/login'),
          throwsA(isA<DioException>()),
        );

        // Cubit state remains AuthInitial (not flipped to AuthGuest)
        expect(authCubitWithClient.state, isA<AuthInitial>());

        // 2. Set user as authenticated
        authRepo.loginResult = const Success(
          UserEntity(
            id: 'c1',
            name: 'عميل',
            email: 'cust@index.com',
            role: UserRole.customer,
          ),
        );
        await authCubitWithClient.login(
          email: 'cust@index.com',
          password: 'pass',
        );
        expect(authCubitWithClient.state, isA<AuthAuthenticated>());

        // 3. Now simulate a stray 401 on a protected endpoint /orders
        await expectLater(
          client.dio.get<dynamic>('/orders'),
          throwsA(isA<DioException>()),
        );

        // onSessionExpired was triggered by ApiClient and cubit emitted AuthGuest
        expect(authCubitWithClient.state, isA<AuthGuest>());
      },
    );
  });
}
