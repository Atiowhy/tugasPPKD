# Instruksi Pembuatan Aplikasi Flutter Absensi (5 Fitur Utama)

Tugas ini adalah membangun aplikasi Flutter untuk absensi dengan 5 fitur utama, menggunakan endpoint API dari `ABSENSI PPKD B6 Latihan.postman_collection.json`.

## 1. Persyaratan Utama & Dependencies
Silakan gunakan package berikut (sudah ditambahkan di `pubspec.yaml`):
1.  **`dio`**: Untuk HTTP requests, *interceptor* (menyisipkan token ke header), dan upload Multipart (foto).
2.  **`flutter_secure_storage`**: Untuk menyimpan `access_token` secara aman. Aplikasi harus mendukung **Auto-Login**: Jika token sudah tersimpan, user langsung masuk ke dalam aplikasi tanpa perlu login ulang.
3.  **`image_picker`**: Untuk memilih gambar foto profil (Kamera/Galeri).
4.  **State Management**: **TIDAK PERLU** menggunakan state management kompleks (seperti Provider/Bloc/GetX). **WAJIB** menggunakan `FutureBuilder` untuk menampilkan state (loading, error, success) saat memanggil API (Get Profile).

## 2. Fitur yang Harus Dibuat (5 Fitur)
1.  **Login (`POST /api/login`)**
    *   Form: Email dan Password.
    *   Berhasil: Simpan token ke `flutter_secure_storage` lalu arahkan ke Profile.
2.  **Register (`POST /api/register`)**
    *   Form: Nama, Email, Password, Jenis Kelamin (L/P), Batch ID, dan Training ID.
    *   *Catatan:* Batch ID dan Training ID wajib menggunakan `DropdownButton` yang datanya di-*fetch* langsung dari API (`GET /api/batches` dan `GET /api/trainings`).
    *   Berhasil: Arahkan pengguna kembali ke halaman Login.
3.  **Get Profile (`GET /api/profile`)**
    *   Ambil data menggunakan layanan Dio API.
    *   Gunakan `FutureBuilder` di UI untuk menampilkan *Loading*, *Error*, dan *Data Profil*.
4.  **Edit Profile (`PUT /api/profile`)**
    *   Form yang berisi data saat ini (pre-filled).
    *   User bisa mengubah nama atau info dasar.
    *   Submit dengan metode PUT ke API.
5.  **Edit Photo Profile (`PUT /api/profile/photo`)**
    *   Gunakan `image_picker` untuk memilih gambar.
    *   Kirim menggunakan `FormData` (Multipart) dari `dio`.

## 3. Struktur Folder yang Diharapkan
Buat arsitektur sederhana seperti berikut:
```text
lib/
 ├── core/
 │   └── constants/
 │       └── api_constants.dart      # Berisi variabel baseUrl API
 ├── data/
 │   ├── models/
 │   │   └── user_model.dart         # Model response API (Profile)
 │   └── services/
 │       ├── auth_service.dart       # Fungsi API: login, register, getToken, logout
 │       └── profile_service.dart    # Fungsi API: getProfile, editProfile, editPhoto
 ├── ui/
 │   ├── screens/
 │   │   ├── splash_screen.dart      # Cek token di flutter_secure_storage (Auto-login)
 │   │   ├── login_screen.dart       
 │   │   ├── register_screen.dart
 │   │   ├── profile_screen.dart     # Memanggil profile_service dengan FutureBuilder
 │   │   └── edit_profile_screen.dart
 │   └── widgets/
 │       └── custom_text_field.dart  # (Opsional) Input field yang bisa dipakai ulang
 └── main.dart                       # Entry point aplikasi
```

## 4. Alur Aplikasi (Splash Screen Logic)
Pada saat aplikasi pertama kali dijalankan (`main.dart`), tampilkan `SplashScreen` terlebih dahulu.
Di `SplashScreen`, periksa Token:
*   `String? token = await secureStorage.read(key: 'auth_token');`
*   Jika token **tidak null**, navigasi langsung ke `ProfileScreen`.
*   Jika token **null**, navigasi ke `LoginScreen`.

Silakan mulai implementasi kode dari bagian `core/constants/api_constants.dart`, `data/services/*`, hingga UI screens.
