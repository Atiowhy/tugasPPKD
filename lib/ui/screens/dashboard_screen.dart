import 'package:flutter/material.dart';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/models/absensi_model.dart';
import '../../data/models/user_model.dart';
import '../../data/services/absensi_service.dart';
import '../../data/services/profile_service.dart';
import '../widgets/glossy_widgets.dart';
import 'history_screen.dart';
import 'process_absensi_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AbsensiService _absensiService = AbsensiService();
  final ProfileService _profileService = ProfileService();

  UserModel? _user;
  List<AbsensiModel> _historyList = [];
  bool _isLoadingData = true;
  final bool _isCheckingIn = false;
  final bool _isCheckingOut = false;
  bool _isSubmittingIzin = false;
  String? _errorMessage;
  String _currentAddress = 'Mencari lokasi...';

  // Theme colors
  Color get _primaryText => Theme.of(context).colorScheme.onSurface;
  Color get _secondaryText =>
      Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
  static const Color _accentBlue = Color(0xFF8EC5FC);
  static const Color _checkInColor = Color(0xFF34D399);
  static const Color _checkOutColor = Color(0xFFFBBF24);
  static const Color _izinColor = Color(0xFF8B5CF6);

  @override
  void initState() {
    super.initState();
    _loadData();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _currentAddress = 'Lokasi nonaktif');
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) setState(() => _currentAddress = 'Izin lokasi ditolak');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _currentAddress = 'Izin ditolak permanen');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark p = placemarks[0];
        String address = [p.street, p.subLocality, p.locality]
            .where((e) => e != null && e.isNotEmpty)
            .join(', ');
        if (mounted) {
          setState(() {
            _currentAddress = address.isEmpty ? 'Lokasi ditemukan' : address;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _currentAddress = 'Gagal memuat lokasi');
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoadingData = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _profileService.getProfile(),
        _absensiService.getHistory(),
      ]);

      if (!mounted) return;
      setState(() {
        _user = results[0] as UserModel;
        _historyList = results[1] as List<AbsensiModel>;
        _isLoadingData = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoadingData = false;
      });
    }
  }

  Future<void> _handleCheckIn() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProcessAbsensiScreen(isCheckIn: true),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _handleCheckOut() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProcessAbsensiScreen(isCheckIn: false),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _handleIzin() async {
    final alasanController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Ajukan Izin',
            style: TextStyle(fontWeight: FontWeight.w600, color: _primaryText),
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: alasanController,
              decoration: InputDecoration(
                labelText: 'Alasan Izin',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
              validator: (val) {
                if (val == null || val.trim().isEmpty)
                  return 'Alasan harus diisi';
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Batal', style: TextStyle(color: _secondaryText)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _izinColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Kirim', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final alasan = alasanController.text.trim();
      setState(() => _isSubmittingIzin = true);

      final res = await _absensiService.submitIzin(alasanIzin: alasan);

      if (!mounted) return;
      setState(() => _isSubmittingIzin = false);

      if (res['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message']),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message']), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- Date helpers ---

  String _getIndonesianDay(int weekday) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return days[weekday - 1];
  }

  String _getIndonesianMonth(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[month - 1];
  }

  String _formatTodayDate() {
    final now = DateTime.now();
    final day = _getIndonesianDay(now.weekday);
    final dd = now.day.toString().padLeft(2, '0');
    final month = _getIndonesianMonth(now.month);
    final year = now.year;
    return '$day, $dd $month $year';
  }

  String _todayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  AbsensiModel? _getTodayRecord() {
    final todayStr = _todayDateString();
    for (final record in _historyList) {
      if (record.date == todayStr) return record;
      // Also check if createdAt starts with today's date
      if (record.date == null &&
          record.createdAt != null &&
          record.createdAt!.startsWith(todayStr)) {
        return record;
      }
    }
    return null;
  }

  int _getThisMonthCount() {
    final now = DateTime.now();
    final monthPrefix = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    return _historyList.where((r) {
      if (r.date != null) return r.date!.startsWith(monthPrefix);
      if (r.createdAt != null) return r.createdAt!.startsWith(monthPrefix);
      return false;
    }).length;
  }

  int _getTotalCheckIns() {
    return _historyList.where((r) => r.checkInTime != null).length;
  }

  int _getTotalCheckOuts() {
    return _historyList.where((r) => r.checkOutTime != null).length;
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '--:--';
    // Handle both "HH:mm:ss" and ISO datetime formats
    if (timeStr.contains('T')) {
      try {
        final dt = DateTime.parse(timeStr);
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {
        return timeStr;
      }
    }
    // "HH:mm:ss" or "HH:mm"
    final parts = timeStr.split(':');
    if (parts.length >= 2) return '${parts[0]}:${parts[1]}';
    return timeStr;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Dashboard Absensi',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: _primaryText,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history_rounded, color: _primaryText),
            tooltip: 'Riwayat',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              ).then((_) => _loadData());
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: _primaryText),
            tooltip: 'Refresh',
            onPressed: _loadData,
          ),
        ],
      ),
      body: GlossyBackground(
        child: _isLoadingData
            ? const Center(child: CircularProgressIndicator(color: _accentBlue))
            : _errorMessage != null
            ? _buildErrorState()
            : _buildContent(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent, fontSize: 15),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentBlue.withOpacity(0.2),
                foregroundColor: _accentBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final todayRecord = _getTodayRecord();

    return RefreshIndicator(
      onRefresh: _loadData,
      color: _accentBlue,
      child: ListView(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
          bottom: 100,
        ),
        children: [
          _buildGreetingHeader(),
          const SizedBox(height: 20),
          _buildTodayStatusCard(todayRecord),
          const SizedBox(height: 16),
          _buildStatisticsCard(),
          const SizedBox(height: 24),
          _buildActionButtons(todayRecord),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildGreetingHeader() {
    final hour = DateTime.now().hour;
    String greeting;
    IconData greetIcon;
    if (hour < 11) {
      greeting = 'Selamat Pagi';
      greetIcon = Icons.wb_sunny_rounded;
    } else if (hour < 15) {
      greeting = 'Selamat Siang';
      greetIcon = Icons.wb_sunny_outlined;
    } else if (hour < 18) {
      greeting = 'Selamat Sore';
      greetIcon = Icons.wb_twilight_rounded;
    } else {
      greeting = 'Selamat Malam';
      greetIcon = Icons.nightlight_round;
    }

    return GlossyCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _accentBlue.withOpacity(0.3),
                  _accentBlue.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(greetIcon, color: _accentBlue, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    color: _secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _user?.name ?? 'Pengguna',
                  style: TextStyle(
                    color: _primaryText,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on, size: 14, color: _secondaryText),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _currentAddress,
                        style: TextStyle(color: _secondaryText, fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _formatTodayDate(),
                  style: TextStyle(color: _secondaryText, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStatusCard(AbsensiModel? record) {
    final checkIn = record?.checkInTime;
    final checkOut = record?.checkOutTime;
    final hasCheckedIn = checkIn != null && checkIn.isNotEmpty;
    final hasCheckedOut = checkOut != null && checkOut.isNotEmpty;

    return GlossyCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: hasCheckedIn ? _checkInColor : _secondaryText,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Status Hari Ini',
                style: TextStyle(
                  color: _primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: hasCheckedIn
                      ? (hasCheckedOut
                            ? _accentBlue.withOpacity(0.15)
                            : _checkInColor.withOpacity(0.15))
                      : Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  record?.status == 'izin'
                      ? 'Izin'
                      : hasCheckedOut
                      ? 'Selesai'
                      : hasCheckedIn
                      ? 'Sedang Bekerja'
                      : 'Belum Absen',
                  style: TextStyle(
                    color: record?.status == 'izin'
                        ? _izinColor
                        : hasCheckedIn
                        ? (hasCheckedOut ? _accentBlue : _checkInColor)
                        : _secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTimeBlock(
                  icon: Icons.login_rounded,
                  label: 'Masuk',
                  time: _formatTime(checkIn),
                  color: _checkInColor,
                  isActive: hasCheckedIn,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withOpacity(0.8),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimeBlock(
                  icon: Icons.logout_rounded,
                  label: 'Pulang',
                  time: _formatTime(checkOut),
                  color: _checkOutColor,
                  isActive: hasCheckedOut,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBlock({
    required IconData icon,
    required String label,
    required String time,
    required Color color,
    required bool isActive,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: isActive ? color : _secondaryText.withOpacity(0.5),
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          time,
          style: TextStyle(
            color: isActive ? _primaryText : _secondaryText.withOpacity(0.5),
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? color : _secondaryText.withOpacity(0.5),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCard() {
    final monthCount = _getThisMonthCount();
    final totalCheckIns = _getTotalCheckIns();
    final totalCheckOuts = _getTotalCheckOuts();
    final now = DateTime.now();
    final monthName = _getIndonesianMonth(now.month);

    return GlossyCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded, color: _accentBlue, size: 22),
              const SizedBox(width: 10),
              Text(
                'Statistik $monthName',
                style: TextStyle(
                  color: _primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  value: '$monthCount',
                  label: 'Hari Hadir',
                  icon: Icons.calendar_today_rounded,
                  color: _accentBlue,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  value: '$totalCheckIns',
                  label: 'Total Masuk',
                  icon: Icons.login_rounded,
                  color: _checkInColor,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  value: '$totalCheckOuts',
                  label: 'Total Pulang',
                  icon: Icons.logout_rounded,
                  color: _checkOutColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: TextStyle(
            color: _primaryText,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: _secondaryText, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons(AbsensiModel? todayRecord) {
    final hasCheckedIn =
        todayRecord?.checkInTime != null &&
        todayRecord!.checkInTime!.isNotEmpty;
    final hasCheckedOut =
        todayRecord?.checkOutTime != null &&
        todayRecord!.checkOutTime!.isNotEmpty;
    final isIzin = todayRecord?.status == 'izin';

    return Column(
      children: [
        Row(
          children: [
            // Absen Masuk button
            Expanded(
              child: _buildActionButton(
                label: 'Absen Masuk',
                icon: Icons.login_rounded,
                color: _checkInColor,
                isLoading: _isCheckingIn,
                isDisabled: hasCheckedIn || isIzin,
                onPressed: (hasCheckedIn || isIzin) ? null : _handleCheckIn,
              ),
            ),
            const SizedBox(width: 16),
            // Absen Pulang button
            Expanded(
              child: _buildActionButton(
                label: 'Absen Pulang',
                icon: Icons.logout_rounded,
                color: _checkOutColor,
                isLoading: _isCheckingOut,
                isDisabled: !hasCheckedIn || hasCheckedOut || isIzin,
                onPressed: (!hasCheckedIn || hasCheckedOut || isIzin)
                    ? null
                    : _handleCheckOut,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                label: 'Ajukan Izin',
                icon: Icons.edit_document,
                color: _izinColor,
                isLoading: _isSubmittingIzin,
                isDisabled: hasCheckedIn || isIzin,
                onPressed: (hasCheckedIn || isIzin) ? null : _handleIzin,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isLoading,
    required bool isDisabled,
    VoidCallback? onPressed,
  }) {
    return GlossyCard(
      borderRadius: 20,
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: isLoading || isDisabled ? null : onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 22),
            decoration: BoxDecoration(
              gradient: isDisabled
                  ? null
                  : LinearGradient(
                      colors: [
                        color.withOpacity(0.25),
                        color.withOpacity(0.08),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                if (isLoading)
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: color,
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDisabled
                          ? Colors.white.withOpacity(0.03)
                          : color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: isDisabled
                          ? _secondaryText.withOpacity(0.4)
                          : color,
                      size: 28,
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isDisabled
                        ? _secondaryText.withOpacity(0.4)
                        : _primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isDisabled) ...[
                  const SizedBox(height: 4),
                  Icon(
                    Icons.check_circle_rounded,
                    color: color.withOpacity(0.4),
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
