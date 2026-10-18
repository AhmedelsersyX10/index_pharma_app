import 'package:dio/dio.dart';
import '../models/user_model.dart';
import 'auth_remote_data_source.dart';

/// Implementation of [AuthRemoteDataSource] using [Dio].
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({
    required Dio dio,
  }) : _dio = dio;

  final Dio _dio;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<dynamic>(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    return _extractUser(response.data, 'user');
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? address,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'email': email,
      'password': password,
    };
    if (phone != null) body['phone'] = phone;
    if (address != null) body['address'] = address;

    final response = await _dio.post<dynamic>(
      '/auth/register',
      data: body,
    );

    return _extractUser(response.data, 'user');
  }

  @override
  Future<UserModel> getMe() async {
    final response = await _dio.get<dynamic>(
      '/auth/me',
    );

    return _extractUser(response.data, 'data');
  }

  UserModel _extractUser(dynamic data, String key) {
    if (data is Map) {
      final userJson = data[key];
      if (userJson is Map<String, dynamic>) {
        return UserModel.fromJson(userJson);
      } else if (userJson is Map) {
        return UserModel.fromJson(Map<String, dynamic>.from(userJson));
      }
    }
    throw const FormatException('Invalid or missing user object in response');
  }
}
