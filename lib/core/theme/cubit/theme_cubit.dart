import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:index_pharma/core/storage/storage_service.dart';

/// Cubit managing the application-wide [ThemeMode] preference.
///
/// Supports [ThemeMode.system] (default), [ThemeMode.light], and [ThemeMode.dark],
/// persisting choices across app launches through [StorageService].
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit({required StorageService storageService})
      : _storageService = storageService,
        super(_resolveInitialThemeMode(storageService));

  final StorageService _storageService;

  static ThemeMode _resolveInitialThemeMode(StorageService storageService) {
    final savedMode = storageService.themeMode;
    switch (savedMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// Updates the current theme mode and persists the choice to [StorageService].
  Future<void> updateThemeMode(ThemeMode mode) async {
    if (state == mode) return;
    emit(mode);
    final String modeString;
    switch (mode) {
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      case ThemeMode.system:
        modeString = 'system';
        break;
    }
    await _storageService.setThemeMode(modeString);
  }
}
