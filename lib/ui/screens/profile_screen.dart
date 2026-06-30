import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/profile_service.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();
  late Future<UserModel> _profileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    setState(() {
      _profileFuture = _profileService.getProfile();
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
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
                  const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 16),
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
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 220.0,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: user.profilePhoto != null
                                    ? Image.network(
                                        user.profilePhoto!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Icon(
                                          Icons.person,
                                          size: 45,
                                          color: Colors.grey.shade400,
                                        ),
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: 45,
                                        color: Colors.grey.shade400,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      title: Text(
                        'Profil Saya',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 4)],
                        ),
                      ),
                      centerTitle: true,
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        onPressed: _handleLogout,
                        tooltip: 'Logout',
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(Icons.person_outline, color: colorScheme.primary),
                                    ),
                                    title: const Text('Nama Lengkap', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    subtitle: Text(
                                      user.name,
                                      style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Divider(color: Colors.grey.shade200, height: 1),
                                  ListTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: colorScheme.secondary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(Icons.email_outlined, color: colorScheme.secondary),
                                    ),
                                    title: const Text('Email', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    subtitle: Text(
                                      user.email,
                                      style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditProfileScreen(user: user),
                                ),
                              );
                              if (result == true) {
                                _loadProfile();
                              }
                            },
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('EDIT PROFIL'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Tidak ada data'));
          }
        },
      ),
    );
  }
}
