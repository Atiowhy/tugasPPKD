import 'package:flutter/material.dart';

import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/data_service.dart';
import '../../data/services/profile_service.dart';
import '../../main.dart';
import '../widgets/glossy_widgets.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

import 'dart:ui' as ui;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();
  final DataService _dataService = DataService();

  late Future<UserModel> _profileFuture;
  late Future<List<Map<String, dynamic>>> _batchesFuture;
  late Future<List<Map<String, dynamic>>> _trainingsFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    setState(() {
      _profileFuture = _profileService.getProfile();
      _batchesFuture = _dataService.getBatches();
      _trainingsFuture = _dataService.getTrainings();
    });
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<UserModel>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadProfile,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final user = snapshot.data!;
            return RefreshIndicator(
              onRefresh: () async {
                _loadProfile();
                await _profileFuture;
              },
              child: FutureBuilder(
                future: Future.wait([_batchesFuture, _trainingsFuture]),
                builder: (context, dataSnapshot) {
                  List<Map<String, dynamic>> batches = [];
                  List<Map<String, dynamic>> trainings = [];
                  if (dataSnapshot.hasData) {
                    batches = dataSnapshot.data![0];
                    trainings = dataSnapshot.data![1];
                  }
                  return CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        expandedHeight: 280.0,
                        pinned: true,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Blurred Background Banner
                              if (user.profilePhoto != null)
                                Image.network(
                                  user.profilePhoto!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
                                )
                              else
                                Container(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
                              
                              // Blur Effect Overlay
                              if (user.profilePhoto != null)
                                Container(
                                  color: Colors.black.withOpacity(0.4),
                                ),
                              
                              // Original Content
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 50),
                                  // Profile Avatar with aesthetic gradient border and glow
                                  Container(
                                    width: 124,
                                    height: 124,
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [Color(0xFF38BDF8), Color(0xFF6366F1), Color(0xFFFB7185)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0x666366F1), // 40% opacity Indigo
                                          blurRadius: 24,
                                          spreadRadius: 4,
                                          offset: Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(4), // Inner gap
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                      ),
                                      child: ClipOval(
                                        child: user.profilePhoto != null
                                            ? Image.network(
                                                user.profilePhoto!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) =>
                                                    Icon(
                                                      Icons.person_rounded,
                                                      size: 54,
                                                      color: Theme.of(context).colorScheme.primary,
                                                    ),
                                              )
                                            : Icon(
                                                Icons.person_rounded,
                                                size: 54,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Quick Name
                                  Text(
                                    user.name,
                                    style: Theme.of(context).textTheme.titleLarge
                                        ?.copyWith(fontWeight: FontWeight.w800, color: Colors.white),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.email,
                                    style: Theme.of(context).textTheme.bodyMedium
                                        ?.copyWith(
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          centerTitle: true,
                        ),
                        actions: [
                          IconButton(
                            icon: Icon(
                              Icons.logout_rounded,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            onPressed: _handleLogout,
                            tooltip: 'Logout',
                          ),
                        ],
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 16.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Personal Info Title
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 8.0,
                                  bottom: 12.0,
                                ),
                                child: Text(
                                  'Informasi Personal',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.5),
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              // Personal Info Card
                              GlossyCard(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    _buildInlineTile(
                                      context: context,
                                      icon: Icons.person_outline_rounded,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                      title: 'Nama Lengkap',
                                      value: user.name,
                                    ),
                                    Divider(
                                      color: Theme.of(
                                        context,
                                      ).dividerColor.withOpacity(0.1),
                                      height: 24,
                                    ),
                                    _buildInlineTile(
                                      context: context,
                                      icon: Icons.email_outlined,
                                      color: Colors.orange,
                                      title: 'Alamat Email',
                                      value: user.email,
                                    ),
                                    Divider(
                                      color: Theme.of(
                                        context,
                                      ).dividerColor.withOpacity(0.1),
                                      height: 24,
                                    ),
                                    _buildInlineTile(
                                      context: context,
                                      icon: Icons.wc_rounded,
                                      color: Colors.teal,
                                      title: 'Jenis Kelamin',
                                      value:
                                          user.jenisKelamin != null &&
                                              user.jenisKelamin!.isNotEmpty
                                          ? user.jenisKelamin!
                                          : 'Belum diatur',
                                    ),
                                    Divider(
                                      color: Theme.of(
                                        context,
                                      ).dividerColor.withOpacity(0.1),
                                      height: 24,
                                    ),
                                    _buildInlineTile(
                                      context: context,
                                      icon: Icons.school_rounded,
                                      color: Colors.indigo,
                                      title: 'Data Batch',
                                      value: _getBatchName(
                                        user.batch,
                                        user.batchId,
                                        batches,
                                      ),
                                    ),
                                    Divider(
                                      color: Theme.of(
                                        context,
                                      ).dividerColor.withOpacity(0.1),
                                      height: 24,
                                    ),
                                    _buildInlineTile(
                                      context: context,
                                      icon: Icons.class_outlined,
                                      color: Colors.purpleAccent,
                                      title: 'Kelas yang Dipilih',
                                      value: _getClassName(
                                        user.training,
                                        user.trainingId,
                                        trainings,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              // Preferences Title
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 8.0,
                                  bottom: 12.0,
                                ),
                                child: Text(
                                  'Pengaturan Aplikasi',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.5),
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              // Dark Mode Card
                              GlossyCard(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color:
                                                MyApp.of(context)?.isDarkMode ==
                                                    true
                                                ? Colors.amber.withOpacity(0.1)
                                                : Colors.indigo.withOpacity(
                                                    0.1,
                                                  ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Icon(
                                            MyApp.of(context)?.isDarkMode ==
                                                    true
                                                ? Icons.dark_mode_rounded
                                                : Icons.light_mode_rounded,
                                            color:
                                                MyApp.of(context)?.isDarkMode ==
                                                    true
                                                ? Colors.amber
                                                : Colors.indigo,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Text(
                                          'Mode Malam',
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Switch(
                                      value:
                                          MyApp.of(context)?.isDarkMode ?? true,
                                      onChanged: (_) {
                                        MyApp.of(context)?.toggleTheme();
                                      },
                                      activeThumbColor: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EditProfileScreen(user: user),
                                    ),
                                  );
                                  if (result == true) {
                                    _loadProfile();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                icon: const Icon(Icons.edit_rounded),
                                label: const Text(
                                  'EDIT PROFIL',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 100), // For bottom nav
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          } else {
            return const Center(child: Text('Tidak ada data'));
          }
        },
      ),
    );
  }

  String _getBatchName(
    dynamic batch,
    int? batchId,
    List<Map<String, dynamic>> batches,
  ) {
    if (batchId != null) {
      try {
        final b = batches.firstWhere(
          (element) => element['id'].toString() == batchId.toString(),
        );
        return b['batch_ke'] != null
            ? 'Angkatan ${b['batch_ke']}'
            : 'Batch ${b['id']}';
      } catch (e) {
        // Not found in list, fallback
      }
    }
    if (batch == null) return 'Belum terdaftar di batch';
    if (batch is Map) {
      return batch['name']?.toString() ??
          batch['title']?.toString() ??
          'Batch Terdaftar';
    }
    return batch.toString();
  }

  String _getClassName(
    dynamic training,
    int? trainingId,
    List<Map<String, dynamic>> trainings,
  ) {
    if (trainingId != null) {
      try {
        final t = trainings.firstWhere(
          (element) => element['id'].toString() == trainingId.toString(),
        );
        return t['title']?.toString() ??
            t['name']?.toString() ??
            'Training ${t['id']}';
      } catch (e) {
        // Not found
      }
    }
    if (training == null) return 'Belum memilih kelas';
    if (training is Map) {
      return training['title']?.toString() ??
          training['name']?.toString() ??
          'Kelas Terdaftar';
    }
    return training.toString();
  }

  Widget _buildInlineTile({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
