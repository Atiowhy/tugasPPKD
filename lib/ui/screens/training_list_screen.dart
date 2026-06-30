import 'package:flutter/material.dart';
import '../../data/models/training_model.dart';
import '../../data/services/data_service.dart';
import 'training_detail_screen.dart';

class TrainingListScreen extends StatefulWidget {
  const TrainingListScreen({super.key});

  @override
  State<TrainingListScreen> createState() => _TrainingListScreenState();
}

class _TrainingListScreenState extends State<TrainingListScreen> {
  final DataService _dataService = DataService();
  late Future<List<TrainingModel>> _trainingsFuture;

  @override
  void initState() {
    super.initState();
    _trainingsFuture = _dataService.getTrainingsModel();
  }

  Future<void> _refreshData() async {
    setState(() {
      _trainingsFuture = _dataService.getTrainingsModel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pelatihan', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<List<TrainingModel>>(
          future: _trainingsFuture,
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
                      'Gagal memuat data:\n${snapshot.error}',
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

            final trainings = snapshot.data ?? [];

            if (trainings.isEmpty) {
              return const Center(
                child: Text('Belum ada pelatihan tersedia.'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: trainings.length,
              itemBuilder: (context, index) {
                final training = trainings[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TrainingDetailScreen(trainingId: training.id),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.school,
                              color: Theme.of(context).colorScheme.secondary,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  training.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (training.description != null && training.description!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    training.description!,
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ]
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.chevron_right, color: Colors.grey.shade400),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
