class ApiConstants {
  static const String baseUrl = 'https://appabsensi.mobileprojp.com/api';

  // Auth
  static const String register = '$baseUrl/register';
  static const String login = '$baseUrl/login';

  // Profile
  static const String profile = '$baseUrl/profile';
  static const String profilePhoto = '$baseUrl/profile/photo';

  // Data
  static const String trainings = '$baseUrl/trainings';
  static const String batches = '$baseUrl/batches';

  // Absensi
  static const String checkIn = '$baseUrl/absen/check-in';
  static const String checkOut = '$baseUrl/absen/check-out';
  static const String historyAbsen = '$baseUrl/absen/history';
  static const String deleteAbsen = '$baseUrl/absen';
}
