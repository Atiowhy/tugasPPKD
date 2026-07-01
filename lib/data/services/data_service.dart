import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../models/training_model.dart';
import 'auth_service.dart';
import 'api_client.dart';

class DataService {
  final Dio _dio = Dio();
  late final ApiClient _apiClient;
  final AuthService _authService = AuthService();

  DataService() {
    _dio.options.headers['Accept'] = 'application/json';
    _apiClient = ApiClient(_dio);
  }

  Future<void> _setAuthHeader() async {
    final token = await _authService.getToken();
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<List<Map<String, dynamic>>> getTrainings() async {
    try {
      await _setAuthHeader();
      final response = await _apiClient.getTrainings();
      final data = response['data'] as List;
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      print('Error getTrainings: $e');
      throw Exception('Gagal memuat training: $e');
    }
  }

  Future<List<TrainingModel>> getTrainingsModel() async {
    try {
      await _setAuthHeader();
      final response = await _apiClient.getTrainings();
      final data = response['data'] as List;
      return data
          .map((e) => TrainingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Gagal memuat daftar pelatihan: $e');
    }
  }

  Future<TrainingModel> getTrainingDetail(int id) async {
    try {
      await _setAuthHeader();
      final response = await _apiClient.getTrainingDetail(id);
      final data = response['data'] as Map<String, dynamic>;
      return TrainingModel.fromJson(data);
    } catch (e) {
      throw Exception('Gagal memuat detail pelatihan: $e');
    }
  }

  Future<List<UserModel>> getUsers({int? page, int? limit}) async {
    try {
      await _setAuthHeader();
      final response = await _apiClient.getUsers(page: page, limit: limit);
      
      // Handle typical pagination response structures
      List dataList;
      if (response['data'] is List) {
        dataList = response['data'] as List;
      } else if (response['data'] != null && response['data']['data'] is List) {
        // e.g., Laravel pagination where users are inside data.data
        dataList = response['data']['data'] as List;
      } else {
        dataList = [];
      }
      
      // Fallback: If API doesn't paginate (ignores limit), slice the list locally
      if (limit != null && page != null && dataList.length > limit) {
        final startIndex = (page - 1) * limit;
        if (startIndex >= dataList.length) {
          dataList = [];
        } else {
          final endIndex = startIndex + limit;
          dataList = dataList.sublist(
              startIndex, endIndex > dataList.length ? dataList.length : endIndex);
        }
      }
      
      return dataList
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is DioException) {
        throw Exception(
          'Gagal memuat pengguna: ${e.response?.data['message'] ?? e.message}',
        );
      }
      throw Exception('Gagal memuat pengguna: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getBatches() async {
    try {
      await _setAuthHeader();
      final response = await _apiClient.getBatches();
      if (response is Map && response.containsKey('data')) {
        final data = response['data'] as List;
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } else if (response is List) {
        return (response as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getBatches: $e');
      throw Exception('Gagal memuat batch: $e');
    }
  }
}
