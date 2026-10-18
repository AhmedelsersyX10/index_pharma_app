import 'package:dio/dio.dart';
import 'package:index_pharma/features/choose_branshs/data/datasources/branch_remote_data_source.dart';
import 'package:index_pharma/features/choose_branshs/data/models/branch_model.dart';

/// Implementation of [BranchRemoteDataSource] using [Dio].
class BranchRemoteDataSourceImpl implements BranchRemoteDataSource {
  const BranchRemoteDataSourceImpl({
    required Dio dio,
  }) : _dio = dio;

  final Dio _dio;

  @override
  Future<List<BranchModel>> getBranches() async {
    final response = await _dio.get<dynamic>('/store/branches');
    final data = response.data;

    if (data is Map) {
      final list = data['data'];
      if (list is List) {
        return list
            .whereType<Map>()
            .map((item) => BranchModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    }

    throw const FormatException('Invalid or missing branches array in response');
  }
}
