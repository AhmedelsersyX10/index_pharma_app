import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'language_state.dart';

/// Cubit managing candidate language selection and persistence via [StorageService].
class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit({
    StorageService? storageService,
    String? initialLocale,
  })  : _storageService = storageService,
        super(
          LanguageState(
            selectedLocale: _normalizeLocale(
              initialLocale ?? storageService?.locale ?? 'ar',
            ),
          ),
        );

  final StorageService? _storageService;

  static String _normalizeLocale(String code) {
    return code.toLowerCase().startsWith('en') ? 'en' : 'ar';
  }

  /// Updates candidate language selection.
  void selectLanguage(String code) {
    final normalized = _normalizeLocale(code);
    if (normalized != state.selectedLocale) {
      emit(state.copyWith(selectedLocale: normalized));
    }
  }

  /// Persists the selected language code through [StorageService].
  Future<void> persistSelection([String? code]) async {
    final targetCode = _normalizeLocale(code ?? state.selectedLocale);
    emit(state.copyWith(isApplying: true, selectedLocale: targetCode));
    await _storageService?.setLocale(targetCode);
    emit(state.copyWith(isApplying: false));
  }
}
