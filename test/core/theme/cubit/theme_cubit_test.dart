import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:index_pharma/core/theme/cubit/theme_cubit.dart';

class _FakeStorageService implements StorageService {
  _FakeStorageService({this.initialThemeMode});

  String? initialThemeMode;
  String? lastPersistedMode;
  int setThemeModeCallCount = 0;

  @override
  String? get themeMode => initialThemeMode;

  @override
  Future<bool> setThemeMode(String mode) async {
    setThemeModeCallCount++;
    lastPersistedMode = mode;
    initialThemeMode = mode;
    return true;
  }

  @override
  String? locale;

  @override
  bool onboardingSeen = false;

  @override
  String? selectedBranchId;

  @override
  Future<bool> clearSelectedBranchId() async => true;

  @override
  Future<bool> setLocale(String locale) async => true;

  @override
  Future<bool> setOnboardingSeen(bool seen) async => true;

  @override
  Future<bool> setSelectedBranchId(String branchId) async => true;
}

void main() {
  group('ThemeCubit - Initial State Resolution', () {
    test('defaults to ThemeMode.system when storage has null', () {
      final storage = _FakeStorageService(initialThemeMode: null);
      final cubit = ThemeCubit(storageService: storage);

      expect(cubit.state, equals(ThemeMode.system));
      cubit.close();
    });

    test('resolves ThemeMode.light when storage has "light"', () {
      final storage = _FakeStorageService(initialThemeMode: 'light');
      final cubit = ThemeCubit(storageService: storage);

      expect(cubit.state, equals(ThemeMode.light));
      cubit.close();
    });

    test('resolves ThemeMode.dark when storage has "dark"', () {
      final storage = _FakeStorageService(initialThemeMode: 'dark');
      final cubit = ThemeCubit(storageService: storage);

      expect(cubit.state, equals(ThemeMode.dark));
      cubit.close();
    });

    test('resolves ThemeMode.system when storage has "system"', () {
      final storage = _FakeStorageService(initialThemeMode: 'system');
      final cubit = ThemeCubit(storageService: storage);

      expect(cubit.state, equals(ThemeMode.system));
      cubit.close();
    });

    test('falls back to ThemeMode.system when storage has unrecognized string', () {
      final storage = _FakeStorageService(initialThemeMode: 'custom_solarized');
      final cubit = ThemeCubit(storageService: storage);

      expect(cubit.state, equals(ThemeMode.system));
      cubit.close();
    });
  });

  group('ThemeCubit - Mode Updates & Persistence', () {
    late _FakeStorageService storage;
    late ThemeCubit cubit;

    setUp(() {
      storage = _FakeStorageService(initialThemeMode: null);
      cubit = ThemeCubit(storageService: storage);
    });

    tearDown(() {
      cubit.close();
    });

    test('updateThemeMode to dark emits ThemeMode.dark and persists "dark"', () async {
      expect(cubit.state, equals(ThemeMode.system));

      await cubit.updateThemeMode(ThemeMode.dark);

      expect(cubit.state, equals(ThemeMode.dark));
      expect(storage.lastPersistedMode, equals('dark'));
      expect(storage.setThemeModeCallCount, equals(1));
    });

    test('updateThemeMode to light emits ThemeMode.light and persists "light"', () async {
      await cubit.updateThemeMode(ThemeMode.light);

      expect(cubit.state, equals(ThemeMode.light));
      expect(storage.lastPersistedMode, equals('light'));
      expect(storage.setThemeModeCallCount, equals(1));
    });

    test('updateThemeMode to system emits ThemeMode.system and persists "system"', () async {
      // First switch to dark
      await cubit.updateThemeMode(ThemeMode.dark);
      expect(cubit.state, equals(ThemeMode.dark));

      // Switch back to system
      await cubit.updateThemeMode(ThemeMode.system);

      expect(cubit.state, equals(ThemeMode.system));
      expect(storage.lastPersistedMode, equals('system'));
      expect(storage.setThemeModeCallCount, equals(2));
    });

    test('updateThemeMode with same mode is no-op', () async {
      expect(cubit.state, equals(ThemeMode.system));

      // Re-apply system
      await cubit.updateThemeMode(ThemeMode.system);

      expect(cubit.state, equals(ThemeMode.system));
      expect(storage.setThemeModeCallCount, equals(0));
    });
  });
}
