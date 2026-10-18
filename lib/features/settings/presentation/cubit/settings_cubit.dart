import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:index_pharma/core/network/api_result.dart';
import '../../domain/repositories/settings_repository.dart';
import 'settings_state.dart';

/// Cubit responsible for retrieving and managing public store/pharmacy settings.
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required SettingsRepository settingsRepository,
  })  : _settingsRepository = settingsRepository,
        super(const SettingsInitial());

  final SettingsRepository _settingsRepository;

  /// Fetches public settings from the backend.
  ///
  /// Emits [SettingsLoading] followed by either [SettingsLoaded] or [SettingsFailure].
  Future<void> fetchSettings() async {
    emit(const SettingsLoading());
    final result = await _settingsRepository.getPublicSettings();

    switch (result) {
      case Success(:final data):
        emit(SettingsLoaded(data));
      case Err(:final failure):
        emit(SettingsFailure(failure));
    }
  }

  /// Alias for [fetchSettings] to support both naming styles.
  Future<void> loadSettings() => fetchSettings();
}
