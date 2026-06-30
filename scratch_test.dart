import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  dio.options.headers['Accept'] = 'application/json';
  dio.options.headers['Authorization'] = 'Bearer 556|0M3YfgCep5eX2lf4sLrApXX7wClgCwHmwdHNP2nJc0711158';
  
  try {
    print('--- /api/users ---');
    final r1 = await dio.get('https://appabsensi.mobileprojp.com/api/users');
    print(r1.data);
  } catch (e) {
    if (e is DioException) {
       print('Users Error: ${e.response?.data}');
    } else {
       print('Users Error: $e');
    }
  }

  try {
    print('\n--- /api/trainings ---');
    final r2 = await dio.get('https://appabsensi.mobileprojp.com/api/trainings');
    print(r2.data);
  } catch (e) {
    if (e is DioException) {
       print('Trainings Error: ${e.response?.data}');
    } else {
       print('Trainings Error: $e');
    }
  }

  try {
    print('\n--- /api/trainings/1 ---');
    final r3 = await dio.get('https://appabsensi.mobileprojp.com/api/trainings/1');
    print(r3.data);
  } catch (e) {
    if (e is DioException) {
       print('Training 1 Error: ${e.response?.data}');
    } else {
       print('Training 1 Error: $e');
    }
  }
}
