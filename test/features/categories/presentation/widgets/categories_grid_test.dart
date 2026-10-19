import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/core/widgets/app_empty_state.dart';
import 'package:index_pharma/core/widgets/app_error_view.dart';
import 'package:index_pharma/features/categories/domain/entities/category.dart';
import 'package:index_pharma/features/categories/domain/repositories/categories_repository.dart';
import 'package:index_pharma/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:index_pharma/features/categories/presentation/widgets/categories_grid.dart';
import 'package:index_pharma/features/categories/presentation/widgets/category_card.dart';

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
  }) {
    return MaterialApp(
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
  }

  group('CategoriesGrid Widget Tests', () {
    testWidgets('renders skeleton during initial/loading state', (tester) async {
      await tester.pumpWidget(buildTestWidget());

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
      expect(find.text('خطأ في الخادم'), findsOneWidget);

      fakeRepository.result = const Success([
        Category(id: '1', name: 'Skincare'),
      ]);

      await tester.tap(find.byType(AppErrorView));
      await tester.pump();
    });
  });
}
