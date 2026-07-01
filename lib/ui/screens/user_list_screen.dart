import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/services/data_service.dart';
import '../widgets/glossy_widgets.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final DataService _dataService = DataService();
  
  List<UserModel> _users = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  final int _limit = 5;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchUsers();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _fetchUsers();
      }
    }
  }

  Future<void> _fetchUsers({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _page = 1;
        _hasMore = true;
        _users.clear();
      });
    }

    if (!_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newUsers = await _dataService.getUsers(page: _page, limit: _limit);
      
      setState(() {
        if (newUsers.length < _limit) {
          _hasMore = false;
        }
        _users.addAll(newUsers);
        _page++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat pengguna: $e')),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    await _fetchUsers(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Daftar Pengguna', style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _users.isEmpty && _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _users.isEmpty && !_isLoading
                ? Center(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Center(
                          child: Text('Belum ada pengguna terdaftar.', style: textTheme.bodyLarge),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
                    itemCount: _users.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _users.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final user = _users[index];
                      final bool hasPhoto = user.profilePhoto != null && user.profilePhoto!.isNotEmpty;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withOpacity(0.04),
                              blurRadius: 24,
                              spreadRadius: 0,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Large Avatar (Squircle)
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: colorScheme.secondary.withOpacity(0.1),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: hasPhoto
                                    ? Image.network(
                                        user.profilePhoto!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Icon(Icons.person_rounded, color: colorScheme.secondary, size: 32),
                                      )
                                    : Icon(Icons.person_rounded, color: colorScheme.secondary, size: 32),
                              ),
                              const SizedBox(width: 16),
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name,
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF1E1B4B), // Deep indigo
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    // Email Pill
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.alternate_email_rounded, size: 12, color: colorScheme.primary),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              user.email,
                                              style: TextStyle(
                                                color: colorScheme.primary,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (user.createdAt != null) ...[
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_month_rounded, size: 12, color: Colors.grey[400]),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Bergabung ${user.createdAt!.substring(0, 10)}',
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              // Aesthetic Action Button (Trailing)
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                ),
                                child: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[400]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
