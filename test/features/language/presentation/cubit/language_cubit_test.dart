import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:index_pharma/features/language/presentation/cubit/language_cubit.dart';
import 'package:index_pharma/features/language/presentation/cubit/language_state.dart';

class _FakeStorageService implements StorageService {
  _FakeStorageService();

  @override
  String? locale;

  @override
  bool onboardingSeen = false;

  @override
  String? selectedBranchId;

  int setLocaleCallCount = 0;
  String? lastPersistedLocale;

  @override
  Future<bool> clearSelectedBranchId() async => true;

  @override
  Future<bool> setLocale(String targetLocale) async {
    setLocaleCallCount++;
    lastPersistedLocale = targetLocale;
    locale = targetLocale;
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

void main() {
  group('LanguageCubit Unit Tests', () {
    late _FakeStorageService storageService;

    setUp(() {
      storageService = _FakeStorageService();
    });

    test('initial state defaults to "ar" when storage is empty', () {
      final cubit = LanguageCubit(storageService: storageService);
      expect(cubit.state, equals(const LanguageState(selectedLocale: 'ar')));
      expect(cubit.state.isApplying, isFalse);
      cubit.close();
    });

    test('initial state restores locale from storageService when available', () {
      storageService.locale = 'en';
      final cubit = LanguageCubit(storageService: storageService);
      expect(cubit.state.selectedLocale, equals('en'));
      cubit.close();
    });

    test('selectLanguage emits new candidate locale when different', () {
      final cubit = LanguageCubit(storageService: storageService);
      expect(cubit.state.selectedLocale, equals('ar'));

      cubit.selectLanguage('en');
      expect(cubit.state.selectedLocale, equals('en'));

      cubit.selectLanguage('ar');
      expect(cubit.state.selectedLocale, equals('ar'));

      cubit.close();
    });

    test('selectLanguage does not emit when given the same locale', () {
      final cubit = LanguageCubit(storageService: storageService);
      final states = <LanguageState>[];
      final sub = cubit.stream.listen(states.add);

      cubit.selectLanguage('ar'); // already 'ar'
      expect(states, isEmpty);

      sub.cancel();
      cubit.close();
    });

    test('persistSelection writes candidate selection to StorageService', () async {
      final cubit = LanguageCubit(storageService: storageService);
      cubit.selectLanguage('en');

      await cubit.persistSelection();

      expect(storageService.setLocaleCallCount, equals(1));
      expect(storageService.lastPersistedLocale, equals('en'));
      expect(storageService.locale, equals('en'));
      expect(cubit.state.isApplying, isFalse);

      cubit.close();
    });

    test('persistSelection with explicit code overrides state selection', () async {
      final cubit = LanguageCubit(storageService: storageService);

      await cubit.persistSelection('en');

      expect(storageService.setLocaleCallCount, equals(1));
      expect(storageService.lastPersistedLocale, equals('en'));
      expect(cubit.state.selectedLocale, equals('en'));

      cubit.close();
    });
  });
}
