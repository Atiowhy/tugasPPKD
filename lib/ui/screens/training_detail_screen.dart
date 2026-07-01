import 'package:flutter/material.dart';
import '../../data/models/training_model.dart';
import '../../data/services/data_service.dart';
import '../widgets/glossy_widgets.dart';

class TrainingDetailScreen extends StatefulWidget {
  final int trainingId;

  const TrainingDetailScreen({super.key, required this.trainingId});

  @override
  State<TrainingDetailScreen> createState() => _TrainingDetailScreenState();
}

class _TrainingDetailScreenState extends State<TrainingDetailScreen> {
  final DataService _dataService = DataService();
  late Future<TrainingModel> _trainingDetailFuture;

  @override
  void initState() {
    super.initState();
    _trainingDetailFuture = _dataService.getTrainingDetail(widget.trainingId);
  }

  Future<void> _refreshData() async {
    setState(() {
      _trainingDetailFuture = _dataService.getTrainingDetail(widget.trainingId);
    });
  }

  Widget _buildInfoRow(IconData icon, String title, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF1E293B), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Detail Pelatihan', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),

      body: GlossyBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshData,
            child: FutureBuilder<TrainingModel>(
              future: _trainingDetailFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                        const SizedBox(height: 16),
                        Text(
                          'Gagal memuat detail:\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshData,
                          child: const Text('COBA LAGI'),
                        )
                      ],
                    ),
                  );
                }

                final training = snapshot.data;
                if (training == null) {
                  return const Center(child: Text('Data tidak ditemukan', style: TextStyle(color: Color(0xFF1E293B))));
                }

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.8)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.school_rounded, size: 48, color: Color(0xFF1E293B)),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              training.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Informasi Pelatihan',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 16),
                      GlossyCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              Icons.description_outlined,
                              'Deskripsi',
                              training.description ?? 'Tidak ada deskripsi',
                            ),
                            _buildInfoRow(
                              Icons.people_outline,
                              'Jumlah Peserta',
                              training.participantCount?.toString() ?? 'Belum ditentukan',
                            ),
                            _buildInfoRow(
                              Icons.check_circle_outline,
                              'Standar Kompetensi',
                              training.standard ?? 'Belum ditentukan',
                            ),
                            _buildInfoRow(
                              Icons.timer_outlined,
                              'Durasi',
                              training.duration ?? 'Belum ditentukan',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

