import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../models/training_model.dart';
import 'auth_service.dart';

class DataService {
  final Dio _dio = Dio();
  final AuthService _authService = AuthService();

  DataService() {
    _dio.options.headers['Accept'] = 'application/json';
  }

  Future<void> _setAuthHeader() async {
    final token = await _authService.getToken();
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<List<Map<String, dynamic>>> getTrainings() async {
    try {
      final response = await _dio.get(ApiConstants.trainings);
      final data = response.data['data'] as List;
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      print('Error getTrainings: $e');
      throw Exception('Gagal memuat training: $e');
    }
  }

  Future<List<TrainingModel>> getTrainingsModel() async {
    try {
      final response = await _dio.get(ApiConstants.trainings);
      final data = response.data['data'] as List;
      return data
          .map((e) => TrainingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Gagal memuat daftar pelatihan: $e');
    }
  }

  Future<TrainingModel> getTrainingDetail(int id) async {
    try {
      final response = await _dio.get('${ApiConstants.trainings}/$id');
      final data = response.data['data'] as Map<String, dynamic>;
      return TrainingModel.fromJson(data);
    } catch (e) {
      throw Exception('Gagal memuat detail pelatihan: $e');
    }
  }

  Future<List<UserModel>> getUsers() async {
    try {
      await _setAuthHeader(); // Ensure token is attached if required
      final response = await _dio.get('${ApiConstants.baseUrl}/users');
      final data = response.data['data'] as List;
      return data
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
      final response = await _dio.get(ApiConstants.batches);
      if (response.data is Map && response.data.containsKey('data')) {
        final data = response.data['data'] as List;
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } else if (response.data is List) {
        return (response.data as List)
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
