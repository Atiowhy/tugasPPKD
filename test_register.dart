import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  dio.options.headers['Accept'] = 'application/json';
  
  try {
    print('Trying Register...');
    final r = await dio.post('https://appabsensi.mobileprojp.com/api/register', data: {
      "name": "Test User",
      "email": "testuser_random99@gmail.com",
      "password": "Password123!",
      "jenis_kelamin": "L",
      "batch_id": 1,
      "training_id": 1
    });
    print('Register Response: ${r.data}');
  } catch (e) {
    if (e is DioException) {
      print('Register Error: ${e.response?.statusCode}');
      print('Data: ${e.response?.data}');
    } else {
      print('Error: $e');
    }
  }
}
