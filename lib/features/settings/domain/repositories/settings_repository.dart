import 'package:index_pharma/core/network/api_result.dart';
import '../entities/public_settings.dart';

/// Contract for accessing store and pharmacy public settings.
abstract interface class SettingsRepository {
  /// Retrieves public store settings from the backend.
  Future<ApiResult<PublicSettings>> getPublicSettings();
}
