import 'package:flutter/material.dart';
import '../../data/models/training_model.dart';
import '../../data/services/data_service.dart';

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
              color: const Color(0xFF06B6D4).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF06B6D4), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
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
      appBar: AppBar(
        title: const Text('Detail Pelatihan', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
      ),
      body: RefreshIndicator(
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
              return const Center(child: Text('Data tidak ditemukan'));
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
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4F46E5).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.school, size: 64, color: Colors.white),
                        const SizedBox(height: 16),
                        Text(
                          training.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Informasi Pelatihan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
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
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
