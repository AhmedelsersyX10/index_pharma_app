import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/di/service_locator.dart';
import 'package:index_pharma/core/network/api_client.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('service_locator_test_');
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return tempDir.path;
    });

    SharedPreferences.setMockInitialValues({});
    await getIt.reset();
  });

  tearDown(() async {
    await getIt.reset();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
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

    test('Core service registrations are eager and ready after setupServiceLocator',
        () async {
      await setupServiceLocator();

      // Both services should be ready immediately after setupServiceLocator
      expect(getIt.isReadySync<ApiClient>(), isTrue);
      expect(getIt.isReadySync<StorageService>(), isTrue);
    });

    test('StorageService resolves synchronously once ready and is fully functional',
        () async {
      await setupServiceLocator();

      final storage = getIt<StorageService>();
      expect(storage, isNotNull);

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
      expect(routePaths, contains(AppRouter.kProductDetailsView));
      expect(appRouter.router.configuration.routes.length, equals(14));
    });
  });
}
