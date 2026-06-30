import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  final paths = [
    'https://appabsensi.mobileprojp.com/storage/profile_photos/profile_1751873230_8dAoy9UA3J.png',
    'https://appabsensi.mobileprojp.com/public/storage/profile_photos/profile_1751873043_kTONaIjTEX.png',
    'https://appabsensi.mobileprojp.com/public/profile_photos/profile_1751873123_d4F4swK7Hq.png'
  ];

  for (var path in paths) {
    try {
      final res = await dio.get(path);
      print('SUCCESS $path -> ${res.statusCode}');
    } catch (e) {
      if (e is DioException) {
        print('FAILED $path -> ${e.response?.statusCode}');
      } else {
        print('FAILED $path -> $e');
      }
    }
  }
}
