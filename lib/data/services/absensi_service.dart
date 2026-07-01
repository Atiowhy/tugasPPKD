import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geocoding/geocoding.dart';
import '../models/absensi_model.dart';
import 'api_client.dart';

class AbsensiService {
  final Dio _dio = Dio();
  late final ApiClient _apiClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';

  AbsensiService() {
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['Content-Type'] = 'application/json';
    _apiClient = ApiClient(_dio);
  }

  /// Mengambil token dan menambahkannya ke header Authorization
  Future<void> _setAuthHeader() async {
    final token = await _storage.read(key: _tokenKey);
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  /// Check In (POST /api/absen-check-in)
  /// Body: { latitude, longitude }
  /// Response sukses: { message, data: { ... } }
  Future<Map<String, dynamic>> checkIn({
    required double latitude,
    required double longitude,
  }) async {
    await _setAuthHeader();

    try {
      final now = DateTime.now();
      final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
      
      String address = "$latitude, $longitude";
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          address = "${p.street}, ${p.subLocality}, ${p.locality}, ${p.administrativeArea}";
        }
      } catch (e) {
        print("Geocoding error: $e");
      }

      final response = await _apiClient.checkIn({
        'attendance_date': dateStr,
        'check_in': timeStr,
        'check_in_lat': latitude,
        'check_in_lng': longitude,
        'check_in_address': address,
        'status': 'masuk',
      });

      return {
        'success': true,
        'message': response['message'] ?? 'Check-in berhasil',
        'data': response['data'],
      };
    } on DioException catch (e) {
      final data = e.response?.data;
      String message = 'Gagal melakukan check-in';

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

  /// Check Out (POST /api/absen-check-out)
  /// Body: { latitude, longitude }
  /// Response sukses: { message, data: { ... } }
  Future<Map<String, dynamic>> checkOut({
    required double latitude,
    required double longitude,
  }) async {
    await _setAuthHeader();

    try {
      final now = DateTime.now();
      final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
      
      String address = "$latitude, $longitude";
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          address = "${p.street}, ${p.subLocality}, ${p.locality}, ${p.administrativeArea}";
        }
      } catch (e) {
        print("Geocoding error: $e");
      }

      final response = await _apiClient.checkOut({
        'attendance_date': dateStr,
        'check_out': timeStr,
        'check_out_lat': latitude.toString(),
        'check_out_lng': longitude.toString(),
        'check_out_location': "$latitude, $longitude",
        'check_out_address': address,
      });

      return {
        'success': true,
        'message': response['message'] ?? 'Check-out berhasil',
        'data': response['data'],
      };
    } on DioException catch (e) {
      final data = e.response?.data;
      String message = 'Gagal melakukan check-out';

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

  /// Get History Absen (GET /api/history-absen)
  /// Response sukses: { message, data: [ { ... }, ... ] }
  Future<List<AbsensiModel>> getHistory() async {
    await _setAuthHeader();

    try {
      final response = await _apiClient.getHistoryAbsen();
      final List<dynamic> data = response['data'] ?? [];
      return data
          .map((item) => AbsensiModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final data = e.response?.data;
      String message = 'Gagal mengambil riwayat absensi';

      if (data != null && data is Map<String, dynamic>) {
        if (data.containsKey('message')) {
          message = data['message'];
        }
      }

      throw Exception(message);
    }
  }

  /// Delete Absen (DELETE /api/delete-absen?id=...)
  /// Response sukses: { message }
  Future<Map<String, dynamic>> deleteAbsen(int id) async {
    await _setAuthHeader();

    try {
      final response = await _apiClient.deleteAbsen(id);

      return {
        'success': true,
        'message': response['message'] ?? 'Absensi berhasil dihapus',
      };
    } on DioException catch (e) {
      final data = e.response?.data;
      String message = 'Gagal menghapus absensi';

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
