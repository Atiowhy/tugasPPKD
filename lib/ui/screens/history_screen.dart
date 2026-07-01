import 'package:flutter/material.dart';
import '../../data/models/absensi_model.dart';
import '../../data/services/absensi_service.dart';
import '../widgets/glossy_widgets.dart';
import 'map_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final AbsensiService _absensiService = AbsensiService();
  late Future<List<AbsensiModel>> _historyFuture;

  // Theme colors
  static const Color _primaryText = Color(0xFF1E293B);
  static const Color _secondaryText = Color(0xFF9CA3AF);
  static const Color _accentBlue = Color(0xFF8EC5FC);
  static const Color _checkInColor = Color(0xFF34D399);
  static const Color _checkOutColor = Color(0xFFFBBF24);

  @override
  void initState() {
    super.initState();
    _historyFuture = _absensiService.getHistory();
  }

  Future<void> _refreshData() async {
    setState(() {
      _historyFuture = _absensiService.getHistory();
    });
  }

  // --- Date / time helpers ---

  String _getIndonesianDay(int weekday) {
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return days[weekday - 1];
  }

  String _getIndonesianMonth(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return months[month - 1];
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final dt = DateTime.parse(dateStr);
      final day = _getIndonesianDay(dt.weekday);
      final dd = dt.day.toString().padLeft(2, '0');
      final month = _getIndonesianMonth(dt.month);
      final year = dt.year;
      return '$day, $dd $month $year';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '--:--';
    if (timeStr.contains('T')) {
      try {
        final dt = DateTime.parse(timeStr);
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {
        return timeStr;
      }
    }
    final parts = timeStr.split(':');
    if (parts.length >= 2) return '${parts[0]}:${parts[1]}';
    return timeStr;
  }

  Future<void> _confirmDelete(AbsensiModel record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hapus Absensi',
          style: TextStyle(color: _primaryText, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus data absensi tanggal ${_formatDate(record.date ?? record.createdAt)}?',
          style: const TextStyle(color: _secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: _secondaryText)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.redAccent,
            ),
            child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final result = await _absensiService.deleteAbsen(record.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Operasi selesai'),
          backgroundColor: result['success'] == true
              ? _checkInColor.withOpacity(0.9)
              : Colors.redAccent.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      if (result['success'] == true) {
        _refreshData();
      }
    }
  }

  void _openMap(double lat, double lng, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapScreen(
          latitude: lat,
          longitude: lng,
          title: title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(

        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Riwayat Absensi',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: _primaryText,
            fontSize: 20,
          ),
        ),
      ),
      body: GlossyBackground(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: _accentBlue,
          child: FutureBuilder<List<AbsensiModel>>(
            future: _historyFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: _accentBlue),
                );
              }

              if (snapshot.hasError) {
                return _buildErrorState(snapshot.error.toString());
              }

              final records = snapshot.data ?? [];

              if (records.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
                  bottom: 100,
                ),
                itemCount: records.length,
                itemBuilder: (context, index) {
                  return _buildHistoryItem(records[index]);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 56, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat data:\n${error.replaceFirst('Exception: ', '')}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent, fontSize: 15),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentBlue.withOpacity(0.2),
                foregroundColor: _accentBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _accentBlue.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 56,
                color: _secondaryText,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum Ada Riwayat',
              style: TextStyle(
                color: _primaryText,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Data riwayat absensi Anda akan\nmuncul di sini setelah melakukan absen.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _secondaryText,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(AbsensiModel record) {
    final dateStr = record.date ?? record.createdAt;
    final hasCheckIn = record.checkInTime != null && record.checkInTime!.isNotEmpty;
    final hasCheckOut = record.checkOutTime != null && record.checkOutTime!.isNotEmpty;

    return GlossyCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header + delete button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.calendar_today_rounded, color: _accentBlue, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _formatDate(dateStr),
                  style: const TextStyle(
                    color: _primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(
                width: 36,
                height: 36,
                child: IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  color: Colors.redAccent.withOpacity(0.7),
                  padding: EdgeInsets.zero,
                  tooltip: 'Hapus',
                  onPressed: () => _confirmDelete(record),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Check-in row
          _buildTimeRow(
            dotColor: _checkInColor,
            label: 'Masuk',
            time: _formatTime(record.checkInTime),
            isActive: hasCheckIn,
          ),
          const SizedBox(height: 10),

          // Check-out row
          _buildTimeRow(
            dotColor: Colors.redAccent,
            label: 'Pulang',
            time: _formatTime(record.checkOutTime),
            isActive: hasCheckOut,
          ),

          // Location info
          if ((record.checkInLatitude != null && record.checkInLongitude != null) ||
              (record.checkOutLatitude != null && record.checkOutLongitude != null)) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: _secondaryText, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Lokasi',
                        style: TextStyle(
                          color: _secondaryText,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (record.checkInLatitude != null && record.checkInLongitude != null)
                    _buildLocationRow(
                      label: 'Masuk',
                      lat: record.checkInLatitude!,
                      lng: record.checkInLongitude!,
                      color: _checkInColor,
                    ),
                  if (record.checkOutLatitude != null && record.checkOutLongitude != null) ...[
                    const SizedBox(height: 6),
                    _buildLocationRow(
                      label: 'Pulang',
                      lat: record.checkOutLatitude!,
                      lng: record.checkOutLongitude!,
                      color: Colors.redAccent,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeRow({
    required Color dotColor,
    required String label,
    required String time,
    required bool isActive,
  }) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: isActive ? dotColor : _secondaryText.withOpacity(0.3),
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [BoxShadow(color: dotColor.withOpacity(0.4), blurRadius: 6, spreadRadius: 1)]
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            color: _secondaryText,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          time,
          style: TextStyle(
            color: isActive ? _primaryText : _secondaryText.withOpacity(0.5),
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationRow({
    required String label,
    required double lat,
    required double lng,
    required Color color,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _openMap(lat, lng, 'Lokasi $label'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              '$label: ',
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
            ),
            Expanded(
              child: Text(
                '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}',
                style: const TextStyle(color: _secondaryText, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.open_in_new_rounded, color: _accentBlue.withOpacity(0.6), size: 14),
          ],
        ),
      ),
    );
  }
}

