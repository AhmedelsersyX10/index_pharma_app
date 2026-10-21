import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/features/settings/domain/entities/public_settings.dart';
import 'package:index_pharma/features/settings/domain/repositories/settings_repository.dart';
import 'package:index_pharma/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:index_pharma/features/settings/presentation/cubit/settings_state.dart';

class FakeSettingsRepository implements SettingsRepository {
  ApiResult<PublicSettings>? result;

  @override
  Future<ApiResult<PublicSettings>> getPublicSettings() async {
    return result!;
  }
}

void main() {
  late FakeSettingsRepository fakeRepository;
  late SettingsCubit cubit;

  const testSettings = PublicSettings(
    pharmacyName: 'Index Pharmacy',
    homeHeroTitle: 'Fast Care',
    whatsappNumber: '01012345678',
  );

  setUp(() {
    fakeRepository = FakeSettingsRepository();
    cubit = SettingsCubit(settingsRepository: fakeRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('SettingsCubit Tests', () {
    test('initial state is SettingsInitial', () {
      expect(cubit.state, equals(const SettingsInitial()));
    });

    test('fetchSettings emits [SettingsLoading, SettingsLoaded] on success', () async {
      fakeRepository.result = const Success(testSettings);

      final states = <SettingsState>[];
      cubit.stream.listen(states.add);

      await cubit.fetchSettings();
      await pumpEventQueue();

      expect(states, [
        const SettingsLoading(),
        const SettingsLoaded(testSettings),
      ]);
      expect((cubit.state as SettingsLoaded).settings.pharmacyName, equals('Index Pharmacy'));
    });

    test('loadSettings alias works and emits [SettingsLoading, SettingsLoaded]', () async {
      fakeRepository.result = const Success(testSettings);

      final states = <SettingsState>[];
      cubit.stream.listen(states.add);

      await cubit.loadSettings();
      await pumpEventQueue();

      expect(states, [
        const SettingsLoading(),
        const SettingsLoaded(testSettings),
      ]);
    });

    test('fetchSettings emits [SettingsLoading, SettingsFailure] on failure', () async {
      const failure = Server(serverMessage: 'تعذر الاتصال بالخادم');
      fakeRepository.result = const Err(failure);

      final states = <SettingsState>[];
      cubit.stream.listen(states.add);

      await cubit.fetchSettings();
      await pumpEventQueue();

      expect(states, [
        const SettingsLoading(),
        const SettingsFailure(failure),
      ]);
      expect(
        (cubit.state as SettingsFailure).message,
        equals(AppLocaleKeys.errorServer.tr()),
      );
    });

    test('SettingsFailure provides fallback message when serverMessage is null', () {
      const failure = Network();
      const state = SettingsFailure(failure);

      expect(state.message, equals(AppLocaleKeys.errorNetwork.tr()));
    });

    test('works for guest context without requiring authentication', () async {
      // Public settings can be fetched freely by guests
      fakeRepository.result = const Success(testSettings);

      await cubit.fetchSettings();

      expect(cubit.state, isA<SettingsLoaded>());
    });
  });
}
