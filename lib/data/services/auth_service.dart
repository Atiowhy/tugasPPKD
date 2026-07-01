import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import 'api_client.dart';

class AuthService {
  final Dio _dio = Dio();
  late final ApiClient _apiClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';

  AuthService() {
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['Content-Type'] = 'application/json';
    _apiClient = ApiClient(_dio);
  }

  /// Register user baru
  /// Body: { name, email, password, jenis_kelamin }
  /// Response sukses: { message, data: { token, user } }
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String jenisKelamin,
    int? batchId,
    int? trainingId,
  }) async {
    try {
      final response = await _apiClient.register({
        'name': name,
        'email': email,
        'password': password,
        'jenis_kelamin': jenisKelamin,
        if (batchId != null) 'batch_id': batchId,
        if (trainingId != null) 'training_id': trainingId,
      });

      return {
        'success': true,
        'message': response['message'] ?? 'Registrasi berhasil',
      };
    } on DioException catch (e) {
      final data = e.response?.data;
      String message = 'Terjadi kesalahan saat registrasi';

      if (data != null && data is Map<String, dynamic>) {
        if (data.containsKey('message')) {
          message = data['message'];
        }
        if (data.containsKey('errors')) {
          final errors = data['errors'] as Map<String, dynamic>;
          final allErrors = errors.values
              .expand((e) => e is List ? e : [e])
              .join('\n');
          message = allErrors;
        }
      }

      return {
        'success': false,
        'message': message,
      };
    }
  }

  /// Login pengguna
  /// Body: { email, password }
  /// Response sukses: { message, data: { token, user } }
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final responseData = await _apiClient.login({
        'email': email,
        'password': password,
      });

      final token = responseData['data']?['token'];
      final userData = responseData['data']?['user'];

      if (token != null) {
        await saveToken(token);
      }

      return {
        'success': true,
        'message': responseData['message'] ?? 'Login berhasil',
        'token': token,
        'user': userData != null ? UserModel.fromJson(userData) : null,
      };
    } on DioException catch (e) {
      final data = e.response?.data;
      String message = 'Terjadi kesalahan saat login';

      if (data != null && data is Map<String, dynamic>) {
        if (data.containsKey('message')) {
          message = data['message'];
        }
      }

      return {
        'success': false,
        'message': message,
      };
    }
  }

  /// Simpan token ke secure storage
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Ambil token dari secure storage
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Hapus token (logout)
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Cek apakah user sudah login (token tersimpan)
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
