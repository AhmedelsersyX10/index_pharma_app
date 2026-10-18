import 'package:dio/dio.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';
import 'package:index_pharma/core/network/error_mapper.dart';
import '../../domain/entities/public_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_remote_data_source.dart';

/// Data layer implementation of [SettingsRepository].
///
/// Retrieves public settings from [SettingsRemoteDataSource], maps them to domain
/// entities, and converts network exceptions into domain [Failure] types.
class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl({
    required SettingsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final SettingsRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<PublicSettings>> getPublicSettings() async {
    try {
      final model = await _remoteDataSource.getPublicSettings();
      return Success(model.toEntity());
    } on DioException catch (e) {
      return Err(e.toFailure());
    } catch (e) {
      return Err(Unexpected(serverMessage: e.toString()));
    }
  }
}
