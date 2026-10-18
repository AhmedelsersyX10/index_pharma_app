import 'package:index_pharma/core/errors/failure.dart';
import '../../domain/entities/public_settings.dart';

/// Sealed hierarchy representing UI states for public store settings.
sealed class SettingsState {
  const SettingsState();
}

/// Initial state before settings have been requested.
final class SettingsInitial extends SettingsState {
  const SettingsInitial();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsInitial && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'SettingsInitial()';
}

/// Loading state emitted while public settings are being retrieved.
final class SettingsLoading extends SettingsState {
  const SettingsLoading();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsLoading && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'SettingsLoading()';
}

/// Loaded state containing verified [settings].
final class SettingsLoaded extends SettingsState {
  const SettingsLoaded(this.settings);

  final PublicSettings settings;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsLoaded &&
          runtimeType == other.runtimeType &&
          settings == other.settings;

  @override
  int get hashCode => Object.hash(runtimeType, settings);

  @override
  String toString() => 'SettingsLoaded(settings: $settings)';
}

/// Failure state wrapping a domain-level [failure].
final class SettingsFailure extends SettingsState {
  const SettingsFailure(this.failure);

  final Failure failure;

  /// User-facing message derived from serverMessage or default.
  String get message => failure.serverMessage ?? 'فشل في تحميل الإعدادات';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsFailure &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  @override
  String toString() => 'SettingsFailure(failure: $failure)';
}
