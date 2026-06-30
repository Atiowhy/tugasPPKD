import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  dio.options.headers['Accept'] = 'application/json';
  
  try {
    print('Fetching Trainings...');
    final r1 = await dio.get('https://appabsensi.mobileprojp.com/api/trainings');
    final data = r1.data['data'] as List;
    final mapped = data.map((e) => e as Map<String, dynamic>).toList();
    print('Trainings Response Length: ${mapped.length}');
  } catch (e) {
    print('Trainings Error: $e');
  }

  try {
    print('\nFetching Batches...');
    final r2 = await dio.get('https://appabsensi.mobileprojp.com/api/batches');
    final data = r2.data['data'] as List;
    final mapped = data.map((e) => e as Map<String, dynamic>).toList();
    print('Batches Response Length: ${mapped.length}');
  } catch (e) {
    print('Batches Error: $e');
  }
}
