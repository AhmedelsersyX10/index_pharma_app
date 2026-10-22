import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/widgets/app_empty_state.dart';
import 'package:index_pharma/core/widgets/app_error_view.dart';
import 'package:index_pharma/features/cart/domain/entities/cart_item.dart';
import 'package:index_pharma/features/cart/domain/repositories/cart_repository.dart';
import 'package:index_pharma/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:index_pharma/features/cart/presentation/cubit/cart_state.dart';
import 'package:index_pharma/features/categories/domain/entities/category.dart';
import 'package:index_pharma/features/categories/domain/repositories/categories_repository.dart';
import 'package:index_pharma/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:index_pharma/features/choose_branches/domain/entities/branch_entity.dart';
import 'package:index_pharma/features/choose_branches/domain/repositories/branch_repository.dart';
import 'package:index_pharma/features/choose_branches/presentation/cubit/branch_cubit.dart';
import 'package:index_pharma/features/home/presentation/screens/home_screen.dart';
import 'package:index_pharma/features/home/presentation/widgets/customer_bottom_nav.dart';
import 'package:index_pharma/features/home/presentation/widgets/home_branch_selector_strip.dart';
import 'package:index_pharma/features/home/presentation/widgets/home_categories_section.dart';
import 'package:index_pharma/features/home/presentation/widgets/home_featured_products_section.dart';
import 'package:index_pharma/features/home/presentation/widgets/home_header_bar.dart';
import 'package:index_pharma/features/home/presentation/widgets/home_hero_banner.dart';
import 'package:index_pharma/features/home/presentation/widgets/home_prescription_upload_card.dart';
import 'package:index_pharma/features/home/presentation/widgets/home_search_bar.dart';
import 'package:index_pharma/features/home/presentation/widgets/home_storage_guarantee_footer.dart';
import 'package:index_pharma/features/products/domain/entities/product.dart';
import 'package:index_pharma/features/products/domain/entities/products_page.dart';
import 'package:index_pharma/features/products/domain/repositories/products_repository.dart';
import 'package:index_pharma/features/products/presentation/cubit/products_cubit.dart';
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

class FakeBranchRepository implements BranchRepository {
  ApiResult<List<BranchEntity>>? result;

  @override
  Future<ApiResult<List<BranchEntity>>> getBranches() async {
    return result ??
        const Success([
          BranchEntity(
            id: 'b1',
            name: 'فرع عباس العقاد - مدينة نصر',
            address: 'مدينة نصر',
            phone: '01012345678',
          ),
        ]);
  }
}

class FakeSettingsRepository implements SettingsRepository {
  ApiResult<PublicSettings>? result;

  @override
  Future<ApiResult<PublicSettings>> getPublicSettings() async {
    return result ??
        const Success(
          PublicSettings(
            pharmacyName: 'إندكس فارما',
            homeHeroTitle: 'صيدليتك الموثوقة في مصر',
            homeHeroDesc: 'أدوية مسجلة ومحفوظة وفق معايير الجودة',
          ),
        );
  }
}

class FakeCategoriesRepository implements CategoriesRepository {
  ApiResult<List<Category>>? result;

  @override
  Future<ApiResult<List<Category>>> getCategories() async {
    return result ??
        const Success([
          Category(id: 'c1', name: 'أدوية القلب والضغط'),
          Category(id: 'c2', name: 'السكري ورعاية الإنسولين'),
        ]);
  }
}

class FakeProductsRepository implements ProductsRepository {
  ApiResult<ProductsPage>? result;

  @override
  Future<ApiResult<ProductsPage>> getProducts({
    required String branchId,
    int page = 1,
    int limit = 20,
    String? keyword,
    String? category,
  }) async {
    return result ??
        const Success(
          ProductsPage(
            products: [
              Product(
                id: 'p1',
                name: 'بنادول إكسترا ٥٠٠ مجم',
                scientificName: 'Paracetamol 500mg',
                sellingPrice: 45.0,
                stockQuantity: 24,
                requiresPrescription: false,
                branchId: 'b1',
              ),
              Product(
                id: 'p2',
                name: 'أوجمنتين ١ جم',
                scientificName: 'Amoxicillin Clavulanate',
                sellingPrice: 99.0,
                stockQuantity: 14,
                requiresPrescription: true,
                branchId: 'b1',
              ),
            ],
            total: 2,
            totalPages: 1,
            page: 1,
            limit: 20,
          ),
        );
  }

  ApiResult<Product>? productDetailResult;

  @override
  Future<ApiResult<Product>> getProductDetails({
    required String productId,
    required String branchId,
  }) async {
    return productDetailResult ??
        Success(
          Product(
            id: productId,
            name: 'بنادول إكسترا ٥٠٠ مجم',
            scientificName: 'Paracetamol 500mg',
            sellingPrice: 45.0,
            stockQuantity: 24,
            requiresPrescription: false,
            branchId: branchId,
          ),
        );
  }
}

class FakeStorageService implements StorageService {
  FakeStorageService({this.selectedBranchId = 'b1'});

  @override
  bool onboardingSeen = true;

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
  Future<bool> setLocale(String locale) async => true;

  @override
  Future<bool> setOnboardingSeen(bool seen) async => true;

  @override
  Future<bool> setSelectedBranchId(String branchId) async {
    selectedBranchId = branchId;
    return true;
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

void main() {
  late FakeBranchRepository fakeBranchRepo;
  late FakeSettingsRepository fakeSettingsRepo;
  late FakeCategoriesRepository fakeCategoriesRepo;
  late FakeProductsRepository fakeProductsRepo;
  late FakeStorageService fakeStorageService;
  late FakeCartRepository fakeCartRepo;

  late BranchCubit branchCubit;
  late SettingsCubit settingsCubit;
  late CategoriesCubit categoriesCubit;
  late ProductsCubit productsCubit;
  late CartCubit cartCubit;

  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();

    final arFile = File('assets/translations/ar.json');
    final enFile = File('assets/translations/en.json');
    _arTranslations =
        jsonDecode(await arFile.readAsString()) as Map<String, dynamic>;
    _enTranslations =
        jsonDecode(await enFile.readAsString()) as Map<String, dynamic>;
  });

  setUp(() {
    fakeBranchRepo = FakeBranchRepository();
    fakeSettingsRepo = FakeSettingsRepository();
    fakeCategoriesRepo = FakeCategoriesRepository();
    fakeProductsRepo = FakeProductsRepository();
    fakeStorageService = FakeStorageService();
    fakeCartRepo = FakeCartRepository();

    branchCubit = BranchCubit(
      branchRepository: fakeBranchRepo,
      storageService: fakeStorageService,
    );
    settingsCubit = SettingsCubit(settingsRepository: fakeSettingsRepo);
    categoriesCubit =
        CategoriesCubit(categoriesRepository: fakeCategoriesRepo);
    productsCubit = ProductsCubit(
      productsRepository: fakeProductsRepo,
      storageService: fakeStorageService,
    );
    cartCubit = CartCubit(
      cartRepository: fakeCartRepo,
      storageService: fakeStorageService,
    );
  });

  tearDown(() {
    branchCubit.close();
    settingsCubit.close();
    categoriesCubit.close();
    productsCubit.close();
    cartCubit.close();
  });

  Widget createTestWidget({
    Locale locale = const Locale('ar'),
  }) {
    return EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      assetLoader: const SynchronousDiskAssetLoader(),
      startLocale: locale,
      saveLocale: false,
      child: Builder(
        builder: (context) {
          return MaterialApp(
            locale: context.locale,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            theme: AppTheme.lightTheme,
            home: HomeScreen(
              branchCubit: branchCubit,
              settingsCubit: settingsCubit,
              categoriesCubit: categoriesCubit,
              productsCubit: productsCubit,
              cartCubit: cartCubit,
            ),
          );
        },
      ),
    );
  }

  group('HomeScreen (Stitch B2) Widget Tests', () {
    testWidgets('renders all B2 sections cleanly in Arabic RTL',
        (tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('ar')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // 1. Header Bar
      expect(find.byType(HomeHeaderBar), findsOneWidget);
      expect(find.text('IP'), findsOneWidget);
      expect(find.text('الرئيسية'), findsAtLeastNWidgets(1));

      // 2. Branch selector strip
      expect(find.byType(HomeBranchSelectorStrip), findsOneWidget);
      expect(find.text('فرع عباس العقاد - مدينة نصر'), findsAtLeastNWidgets(1));
      expect(find.text('متاح للطلب الفوري'), findsOneWidget);

      // 3. Search Bar
      expect(find.byType(HomeSearchBar), findsOneWidget);
      // Verify barcode scanner icon is NOT present per decisions
      expect(find.byIcon(Icons.barcode_reader), findsNothing);
      expect(find.byIcon(Icons.qr_code_scanner), findsNothing);

      // 4. Hero Banner
      expect(find.byType(HomeHeroBanner), findsOneWidget);
      expect(find.text('اعتماد الرقابة الدوائية'), findsOneWidget);
      expect(find.text('صيدليتك الموثوقة في مصر'), findsOneWidget);
      expect(find.text('تسوق الأدوية الآن'), findsOneWidget);

      // 5. Prescription Upload Card
      expect(find.byType(HomePrescriptionUploadCard), findsOneWidget);
      expect(find.text('خدمة صرف الروشتات'), findsOneWidget);
      expect(find.text('آمن وسري'), findsOneWidget);
      expect(find.text('ارفع الروشتة الطبية'), findsOneWidget);

      // 6. Categories Section
      expect(find.byType(HomeCategoriesSection), findsOneWidget);
      expect(find.text('أدوية القلب والضغط'), findsOneWidget);
      expect(find.text('السكري ورعاية الإنسولين'), findsOneWidget);

      // 7. Featured Products Section
      expect(find.byType(HomeFeaturedProductsSection), findsOneWidget);
      expect(find.text('أدوية مسجلة وموثوقة'), findsOneWidget);
      expect(find.text('بنادول إكسترا ٥٠٠ مجم'), findsOneWidget);
      expect(find.text('أوجمنتين ١ جم'), findsOneWidget);

      // 8. Storage Guarantee Footer
      expect(find.byType(HomeStorageGuaranteeFooter), findsOneWidget);
      expect(find.text(AppLocaleKeys.homeGuaranteeTitle.tr()), findsOneWidget);

      // 9. Customer Bottom Navigation (5 tabs, NO Deals tab per Decision 0.6)
      expect(find.byType(CustomerBottomNav), findsOneWidget);
      expect(find.text('تصفح'), findsOneWidget);
      expect(find.text('روشتة'), findsOneWidget);
      expect(find.text('طلباتي'), findsOneWidget);
      expect(find.text('حسابي'), findsOneWidget);
      expect(find.text('عروض'), findsNothing);
      expect(find.text('Deals'), findsNothing);
    });

    testWidgets('renders all B2 sections cleanly in English LTR',
        (tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('en')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.byType(HomeHeaderBar), findsOneWidget);
      expect(find.text('Home'), findsAtLeastNWidgets(1));
      expect(find.text('Live Stock'), findsOneWidget);
      expect(find.text('EDA Regulatory Compliance'), findsOneWidget);
      expect(find.text('Shop Medications Now'), findsOneWidget);
      expect(find.text('Doctor verification'), findsOneWidget);
      expect(find.text('Upload Prescription'), findsOneWidget);
      expect(find.text('Essential Pharmaceuticals'), findsOneWidget);
      expect(find.text('Licensed Pharmacist Care'), findsOneWidget);

      // Bottom nav English
      expect(find.text('Browse'), findsOneWidget);
      expect(find.text('Prescription'), findsOneWidget);
      expect(find.text('My Orders'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Deals'), findsNothing);
    });

    testWidgets(
        'isolated product failure does NOT blank the whole page, shows retry view',
        (tester) async {
      fakeProductsRepo.result = const Err(
        Network(serverMessage: 'تعذر تحميل المنتجات'),
      );

      await tester.pumpWidget(createTestWidget(locale: const Locale('ar')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Hero banner and categories STILL render safely
      expect(find.byType(HomeHeroBanner), findsOneWidget);
      expect(find.byType(HomeCategoriesSection), findsOneWidget);
      expect(find.text('أدوية القلب والضغط'), findsOneWidget);

      // Product section displays isolated error view
      expect(find.byType(AppErrorView), findsOneWidget);
      expect(find.text(AppLocaleKeys.errorNetwork.tr()), findsOneWidget);
      expect(find.byType(HomeStorageGuaranteeFooter), findsOneWidget);
    });

    testWidgets(
        'empty products list displays AppEmptyState in featured products section',
        (tester) async {
      fakeProductsRepo.result = const Success(
        ProductsPage(
          products: [],
          total: 0,
          totalPages: 0,
          page: 1,
          limit: 20,
        ),
      );

      await tester.pumpWidget(createTestWidget(locale: const Locale('ar')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Featured products section displays AppEmptyState
      expect(find.byType(HomeFeaturedProductsSection), findsOneWidget);
      expect(find.byType(AppEmptyState), findsOneWidget);
      expect(find.text('لم يتم العثور على أدوية'), findsOneWidget);
    });

    testWidgets(
        'tapping add to cart on featured product puts product in CartCubit state, updates badge, and shows success SnackBar',
        (tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('ar')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(cartCubit.state, isA<CartEmpty>());

      final addToCartFinder = find.widgetWithText(
        ElevatedButton,
        AppLocaleKeys.productsAddToCart.tr(),
      );

      // Scroll down until the add-to-cart button itself is visible on screen
      await tester.scrollUntilVisible(
        addToCartFinder.first,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(addToCartFinder.first);
      await tester.pumpAndSettle();

      // Product is really added to CartCubit
      expect(cartCubit.state, isA<CartHasItems>());
      final cartState = cartCubit.state as CartHasItems;
      expect(cartState.totalItemsCount, equals(1));
      expect(cartState.items.first.product.name, equals('بنادول إكسترا ٥٠٠ مجم'));

      // Cart badge in HomeHeaderBar is updated to 1
      expect(find.text('1'), findsOneWidget);

      // Success SnackBar is displayed
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text(
          AppLocaleKeys.cartItemAddedSuccess.tr(args: ['بنادول إكسترا ٥٠٠ مجم']),
        ),
        findsOneWidget,
      );
    });
  });
}
