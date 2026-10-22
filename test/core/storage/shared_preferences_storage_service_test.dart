import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/storage/shared_preferences_storage_service.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storageService;

  group('SharedPreferencesStorageService', () {
    test('returns correct default values when storage is empty', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storageService = SharedPreferencesStorageService(prefs);

      expect(storageService.locale, isNull);
      expect(storageService.selectedBranchId, isNull);
      expect(storageService.onboardingSeen, isFalse);
      expect(storageService.themeMode, isNull);
    });

    test('reads initial values when pre-populated in SharedPreferences',
        () async {
      SharedPreferences.setMockInitialValues({
        SharedPreferencesStorageService.keyLocale: 'ar',
        SharedPreferencesStorageService.keySelectedBranchId: 'branch-101',
        SharedPreferencesStorageService.keyOnboardingSeen: true,
        SharedPreferencesStorageService.keyThemeMode: 'dark',
      });
      final prefs = await SharedPreferences.getInstance();
      storageService = SharedPreferencesStorageService(prefs);

      expect(storageService.locale, equals('ar'));
      expect(storageService.selectedBranchId, equals('branch-101'));
      expect(storageService.onboardingSeen, isTrue);
      expect(storageService.themeMode, equals('dark'));
    });

    group('round trip set and get', () {
      setUp(() async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        storageService = SharedPreferencesStorageService(prefs);
      });

      test('persists and retrieves locale', () async {
        expect(storageService.locale, isNull);

        final resultAr = await storageService.setLocale('ar');
        expect(resultAr, isTrue);
        expect(storageService.locale, equals('ar'));

        final resultEn = await storageService.setLocale('en');
        expect(resultEn, isTrue);
        expect(storageService.locale, equals('en'));
      });

      test('persists and retrieves selectedBranchId', () async {
        expect(storageService.selectedBranchId, isNull);

        final result = await storageService.setSelectedBranchId('branch-42');
        expect(result, isTrue);
        expect(storageService.selectedBranchId, equals('branch-42'));
      });

      test('persists and retrieves onboardingSeen', () async {
        expect(storageService.onboardingSeen, isFalse);

        final resultSetTrue = await storageService.setOnboardingSeen(true);
        expect(resultSetTrue, isTrue);
        expect(storageService.onboardingSeen, isTrue);

        final resultSetFalse = await storageService.setOnboardingSeen(false);
        expect(resultSetFalse, isTrue);
        expect(storageService.onboardingSeen, isFalse);
      });

      test('persists and retrieves themeMode', () async {
        expect(storageService.themeMode, isNull);

        final resultDark = await storageService.setThemeMode('dark');
        expect(resultDark, isTrue);
        expect(storageService.themeMode, equals('dark'));

        final resultLight = await storageService.setThemeMode('light');
        expect(resultLight, isTrue);
        expect(storageService.themeMode, equals('light'));

        final resultSystem = await storageService.setThemeMode('system');
        expect(resultSystem, isTrue);
        expect(storageService.themeMode, equals('system'));
      });
    });

    group('clearing values', () {
      setUp(() async {
        SharedPreferences.setMockInitialValues({
          SharedPreferencesStorageService.keySelectedBranchId: 'branch-999',
        });
        final prefs = await SharedPreferences.getInstance();
        storageService = SharedPreferencesStorageService(prefs);
      });

      test('clears selectedBranchId without modifying other keys', () async {
        await storageService.setLocale('ar');
        await storageService.setOnboardingSeen(true);

        expect(storageService.selectedBranchId, equals('branch-999'));

        final clearResult = await storageService.clearSelectedBranchId();
        expect(clearResult, isTrue);
        expect(storageService.selectedBranchId, isNull);

        // Ensure other preferences were preserved
        expect(storageService.locale, equals('ar'));
        expect(storageService.onboardingSeen, isTrue);
      });

      test('clearSelectedBranchId is idempotent when branchId is already null', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        final emptyStorageService = SharedPreferencesStorageService(prefs);

        expect(emptyStorageService.selectedBranchId, isNull);
        final clearResult = await emptyStorageService.clearSelectedBranchId();
        expect(clearResult, isTrue);
        expect(emptyStorageService.selectedBranchId, isNull);
      });

      test('sequential updates overwrite previous values correctly', () async {
        await storageService.setSelectedBranchId('branch-1');
        expect(storageService.selectedBranchId, equals('branch-1'));

        await storageService.setSelectedBranchId('branch-2');
        expect(storageService.selectedBranchId, equals('branch-2'));

        await storageService.setLocale('en');
        expect(storageService.locale, equals('en'));

        await storageService.setLocale('ar');
        expect(storageService.locale, equals('ar'));
      });
    });
  });
}
