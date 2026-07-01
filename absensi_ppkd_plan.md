# Rencana Pengembangan: Aplikasi Absensi PPKD

File ini berisi rencana langkah demi langkah untuk mengembangkan aplikasi "Absensi PPKD" sesuai dengan instruksi yang diberikan pada studi kasus. Rencana ini disiapkan dengan pendekatan *Clean Architecture* dan *Clean Code*.

## 1. Persiapan Proyek & Arsitektur
- **Inisialisasi**: Buat proyek Flutter baru (misal: `flutter create absensi_ppkd`).
- **Dependensi Utama** (tambahkan di `pubspec.yaml`):
  - Jaringan: `dio` atau `http` (Disarankan `dio` + `retrofit` untuk kode yang lebih rapi).
  - Penyimpanan Lokal: `shared_preferences` (untuk token dan preferensi tema).
  - Lokasi: `geolocator` (untuk mendapatkan latitude & longitude).
  - Peta: `google_maps_flutter` (untuk menampilkan peta lokasi absensi).
  - State Management: `provider` atau `flutter_bloc` sesuai preferensi.
- **Struktur Folder (Saran)**:
  - `lib/core/` (Konfigurasi, constants, utilities, error handling).
  - `lib/data/` (Models, API services/clients, repositories).
  - `lib/ui/` (Screens, widgets, theme, state/bloc).

## 2. Konfigurasi Jaringan (REST API)
- **Base URL**: `https://appabsensi.mobileprojp.com`
- **Konfigurasi HTTP Client**: Buat *interceptor* API yang secara otomatis menyisipkan `Authorization: Bearer <token>` untuk semua *request* (kecuali `login` dan `register`). Ambil token dari `SharedPreferences`.

## 3. Modul Autentikasi
- **Registrasi (`POST /register`)**:
  - Halaman `RegisterScreen` dengan form: Nama, Email, ID Training, Batch, dan Password.
  - Saat berhasil, API akan mengembalikan token. Simpan token ke `SharedPreferences` dan navigasi ke Dashboard.
- **Login (`POST /login`)**:
  - Halaman `LoginScreen` dengan form: Email dan Password.
  - Saat berhasil, simpan token ke `SharedPreferences` dan navigasi ke Dashboard.

## 4. Modul Dashboard (Absensi)
- **Tampilan Dashboard (`DashboardScreen`)**:
  - Header: Tampilkan sapaan (greeting), Nama Pengguna, dan Tanggal hari ini.
  - Statistik: Tampilkan statistik absen secara umum dan info absensi hari ini.
- **Aksi Absensi**:
  - Gunakan `geolocator` untuk mendapatkan `latitude` dan `longitude` secara *real-time*.
  - **Absen Masuk**: Tombol yang memicu endpoint `POST /absen-check-in` dengan *payload* lat & long.
  - **Absen Pulang**: Tombol yang memicu endpoint `POST /absen-check-out` dengan *payload* lat & long.
- **Peta Lokasi**: Integrasikan `google_maps_flutter` (bisa di dalam widget detail atau langsung di halaman absensi) untuk memvisualisasikan titik lokasi (*marker*) dari latitude & longitude yang didapat.

## 5. Modul Riwayat Absensi
- **Tampilan Riwayat (`HistoryScreen`)**:
  - Panggil endpoint `GET /history-absen`.
  - Tampilkan data dalam bentuk daftar (List).
  - Informasi per item: Tanggal, Jam Masuk, Jam Keluar, dan Lokasi (Lat/Long).
- **Aksi Hapus Absen (Fitur Bonus)**:
  - Sediakan fungsi hapus (misal: *swipe-to-delete* atau tombol *delete*).
  - Panggil endpoint `DELETE /delete-absen?id=<absen_id>`.

## 6. Modul Profil Pengguna
- **Tampilan Profil (`ProfileScreen`)**:
  - Panggil endpoint `GET /profile` untuk mendapatkan data user saat ini.
  - Tampilkan informasi Nama, Email, dan data relevan lainnya.
- **Edit Profil (`PUT /edit-profile`)**:
  - Halaman/form `EditProfileScreen` untuk mengubah Nama dan Email pengguna.
- **Fungsi Logout (Fitur Bonus)**:
  - Tombol **Logout** yang akan menghapus token dari `SharedPreferences`.
  - Navigasi ulang pengguna ke halaman `LoginScreen` dan bersihkan *navigation stack*.

## 7. Fitur Bonus Tambahan: Dark / Light Mode
- **Manajemen Tema**:
  - Buat definisi `ThemeData` untuk versi terang (Light) dan gelap (Dark).
  - Terapkan ke dalam aplikasi menggunakan parameter `themeMode` pada `MaterialApp`.
  - Buat *toggle* atau *switch* (misalnya diletakkan di `ProfileScreen`) untuk mengganti tema.
  - Simpan pilihan tema di `SharedPreferences` sehingga saat aplikasi di-*restart*, tema akan tetap bertahan.

## 8. Referensi Desain dan Dokumentasi
- **Figma (Panduan UI)**: [Desain Figma Absensi PPKD](https://www.figma.com/design/GheFokv6sVoKqtY4k2lt9x/Absensi-PPKD?node-id=0-1&t=dWhq4ny9sKbr4lpr-1)
- **Postman (Dokumentasi API)**: [Postman Collection](https://drive.google.com/file/d/1_QNZ-d8HwihntMzQ4PXHNqNxyJ15WuMz/view?usp=sharing)
