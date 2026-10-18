import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/di/service_locator.dart';
import 'package:index_pharma/core/network/api_client.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await getIt.reset();
  });

  tearDown(() async {
    await getIt.reset();
  });

  group('ServiceLocator', () {
    test('setupServiceLocator registers ApiClient, StorageService, and AppRouter', () async {
      expect(getIt.isRegistered<ApiClient>(), isFalse);
      expect(getIt.isRegistered<StorageService>(), isFalse);
      expect(getIt.isRegistered<AppRouter>(), isFalse);

      await setupServiceLocator();

      expect(getIt.isRegistered<ApiClient>(), isTrue);
      expect(getIt.isRegistered<StorageService>(), isTrue);
      expect(getIt.isRegistered<AppRouter>(), isTrue);
    });

    test('setupServiceLocator avoids duplicate registrations on multiple calls',
        () async {
      await setupServiceLocator();
      expect(getIt.isRegistered<ApiClient>(), isTrue);
      expect(getIt.isRegistered<StorageService>(), isTrue);

      // Calling setupServiceLocator a second time should not throw
      expect(() => setupServiceLocator(), returnsNormally);
      expect(getIt.isRegistered<ApiClient>(), isTrue);
      expect(getIt.isRegistered<StorageService>(), isTrue);
    });

    test('Core service registrations are lazy (not instantiated until requested)',
        () async {
      await setupServiceLocator();

      // Before accessing them, the instances should not be ready/instantiated yet
      expect(getIt.isReadySync<ApiClient>(), isFalse);
      expect(getIt.isReadySync<StorageService>(), isFalse);
    });

    test('StorageService resolves asynchronously and returns functional instance',
        () async {
      await setupServiceLocator();

      final storage = await getIt.getAsync<StorageService>();
      expect(storage, isNotNull);
      expect(getIt.isReadySync<StorageService>(), isTrue);

      await storage.setSelectedBranchId('di-branch-1');
      expect(storage.selectedBranchId, equals('di-branch-1'));
    });

    test('AppRouter resolves synchronously and provides functional GoRouter instance',
        () async {
      await setupServiceLocator();

      final appRouter = getIt<AppRouter>();
      expect(appRouter, isA<AppRouter>());
      final routePaths = appRouter.router.configuration.routes
          .whereType<GoRoute>()
          .map((r) => r.path)
          .toList();
      expect(routePaths, contains(AppRouter.kBranchSelectionView));
      expect(appRouter.router.configuration.routes.length, equals(8));
    });
  });
}
