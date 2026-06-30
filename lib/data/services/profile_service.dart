import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../../core/constants/api_constants.dart';

class ProfileService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';

  ProfileService() {
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  /// Mengambil token dan menambahkannya ke header Authorization
  Future<void> _setAuthHeader() async {
    final token = await _storage.read(key: _tokenKey);
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  /// Get Profile (GET /api/profile)
  /// Response sukses: { message, data: { id, name, email, ... } }
  Future<UserModel> getProfile() async {
    await _setAuthHeader();

    try {
      final response = await _dio.get(ApiConstants.profile);
      final userData = response.data['data'];
      return UserModel.fromJson(userData);
    } on DioException catch (e) {
      final data = e.response?.data;
      String message = 'Gagal mengambil data profil';

      if (data != null && data is Map<String, dynamic>) {
        if (data.containsKey('message')) {
          message = data['message'];
        }
      }

      throw Exception(message);
    }
  }

  /// Edit Profile (PUT /api/profile)
  /// Body: { name }
  /// Response sukses: { message, data: { id, name, email, ... } }
  Future<Map<String, dynamic>> editProfile({required String name}) async {
    await _setAuthHeader();

    try {
      final response = await _dio.put(
        ApiConstants.profile,
        data: {'name': name},
      );

      return {
        'success': true,
        'message': response.data['message'] ?? 'Profil berhasil diperbarui',
        'user': UserModel.fromJson(response.data['data']),
      };
    } on DioException catch (e) {
      final data = e.response?.data;
      String message = 'Gagal memperbarui profil';

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

  /// Edit Profile Photo (PUT /api/profile/photo)
  /// Body: { profile_photo: "data:image/png;base64,..." }
  /// Response sukses: { message, data: { profile_photo: "url" } }
  Future<Map<String, dynamic>> editProfilePhoto(File imageFile) async {
    await _setAuthHeader();

    try {
      // Baca file dan encode ke base64 dengan data URI
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);

      // Tentukan mime type dari ekstensi file
      String mimeType = 'image/jpeg';
      final extension = imageFile.path.split('.').last.toLowerCase();
      if (extension == 'png') {
        mimeType = 'image/png';
      } else if (extension == 'gif') {
        mimeType = 'image/gif';
      }

      final dataUri = 'data:$mimeType;base64,$base64String';

      final response = await _dio.put(
        ApiConstants.profilePhoto,
        data: {'profile_photo': dataUri},
      );

      return {
        'success': true,
        'message':
            response.data['message'] ?? 'Foto profil berhasil diperbarui',
        'profile_photo': response.data['data']?['profile_photo'],
      };
    } on DioException catch (e) {
      final data = e.response?.data;
      String message = 'Gagal memperbarui foto profil';

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
}
