import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/widgets/app_empty_state.dart';
import 'package:index_pharma/core/widgets/app_error_view.dart';
import 'package:index_pharma/features/categories/domain/entities/category.dart';
import 'package:index_pharma/features/categories/domain/repositories/categories_repository.dart';
import 'package:index_pharma/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:index_pharma/features/categories/presentation/widgets/categories_grid.dart';
import 'package:index_pharma/features/categories/presentation/widgets/category_card.dart';
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

class FakeCategoriesRepository implements CategoriesRepository {
  ApiResult<List<Category>>? result;

  @override
  Future<ApiResult<List<Category>>> getCategories() async {
    return result ?? const Success([]);
  }
}

void main() {
  late FakeCategoriesRepository fakeRepository;
  late CategoriesCubit cubit;

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
    fakeRepository = FakeCategoriesRepository();
    cubit = CategoriesCubit(categoriesRepository: fakeRepository);
  });

  tearDown(() {
    cubit.close();
  });

  Widget buildTestWidget({
    ValueChanged<Category>? onCategorySelected,
    VoidCallback? onViewAll,
    Locale locale = const Locale('ar'),
  }) {
    return EasyLocalization(
      key: ValueKey('EasyLocalization_${locale.languageCode}'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: locale,
      saveLocale: false,
      useOnlyLangCode: true,
      assetLoader: const SynchronousDiskAssetLoader(),
      child: Builder(
        builder: (context) {
          return MaterialApp(
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: BlocProvider<CategoriesCubit>.value(
                value: cubit,
                child: SingleChildScrollView(
                  child: CategoriesGrid(
                    onCategorySelected: onCategorySelected,
                    onViewAll: onViewAll,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  group('CategoriesGrid Widget Tests', () {
    testWidgets('renders skeleton during initial/loading state', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(CategoryCard), findsNothing);
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('renders AppEmptyState when categories list is empty', (tester) async {
      fakeRepository.result = const Success(<Category>[]);
      await cubit.fetchCategories();

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(AppEmptyState), findsOneWidget);
      expect(find.byType(CategoryCard), findsNothing);
    });

    testWidgets('renders CategoryCard items when categories are loaded', (tester) async {
      const categories = [
        Category(id: '1', name: 'Skincare'),
        Category(id: '2', name: 'Vitamins'),
      ];
      fakeRepository.result = const Success(categories);
      await cubit.fetchCategories();

      Category? selectedCategory;
      await tester.pumpWidget(
        buildTestWidget(
          onCategorySelected: (cat) => selectedCategory = cat,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CategoryCard), findsNWidgets(2));
      expect(find.text('Skincare'), findsOneWidget);
      expect(find.text('Vitamins'), findsOneWidget);

      await tester.tap(find.text('Skincare'));
      expect(selectedCategory, equals(categories[0]));
    });

    testWidgets('renders AppErrorView on failure and triggers retry', (tester) async {
      const failure = Server(serverMessage: 'خطأ في الخادم');
      fakeRepository.result = const Err(failure);
      await cubit.fetchCategories();

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(AppErrorView), findsOneWidget);
      expect(find.text(AppLocaleKeys.errorServer.tr()), findsOneWidget);

      fakeRepository.result = const Success([
        Category(id: '1', name: 'Skincare'),
      ]);

      await tester.tap(find.byType(AppErrorView));
      await tester.pump();
    });
  });
}
