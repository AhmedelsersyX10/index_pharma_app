import 'package:dio/dio.dart';
import '../models/public_settings_model.dart';
import 'settings_remote_data_source.dart';

/// Implementation of [SettingsRemoteDataSource] using [Dio].
class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  const SettingsRemoteDataSourceImpl({
    required Dio dio,
  }) : _dio = dio;

  final Dio _dio;

  @override
  Future<PublicSettingsModel> getPublicSettings() async {
    final response = await _dio.get<dynamic>('/settings/public');
    final data = response.data;

    if (data is Map) {
      final settingsData = data['data'];
      if (settingsData is Map) {
        return PublicSettingsModel.fromJson(
          Map<String, dynamic>.from(settingsData),
        );
      }
      return PublicSettingsModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw const FormatException(
      'Invalid or missing settings object in response',
    );
  }
}
