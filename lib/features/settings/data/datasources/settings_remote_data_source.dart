import '../models/public_settings_model.dart';

/// Contract for fetching settings from the remote backend.
abstract interface class SettingsRemoteDataSource {
  /// Calls `GET /settings/public` to retrieve public store and pharmacy settings.
  Future<PublicSettingsModel> getPublicSettings();
}
