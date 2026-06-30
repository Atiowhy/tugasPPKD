import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/services/data_service.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final DataService _dataService = DataService();
  late Future<List<UserModel>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _dataService.getUsers();
  }

  Future<void> _refreshData() async {
    setState(() {
      _usersFuture = _dataService.getUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengguna', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<List<UserModel>>(
          future: _usersFuture,
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

            final users = snapshot.data ?? [];

            if (users.isEmpty) {
              return const Center(
                child: Text('Belum ada pengguna terdaftar.'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final bool hasPhoto = user.profilePhoto != null && user.profilePhoto!.isNotEmpty;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: hasPhoto
                          ? Image.network(
                              user.profilePhoto!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.person,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            )
                          : Icon(
                              Icons.person,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                    ),
                    title: Text(
                      user.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.email_outlined, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                user.email,
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (user.createdAt != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.date_range_outlined, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                'Terdaftar: ${user.createdAt!.substring(0, 10)}',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              ),
                            ],
                          ),
                        ]
                      ],
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
