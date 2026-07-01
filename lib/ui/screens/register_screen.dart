import 'package:flutter/material.dart';

import '../../data/services/auth_service.dart';
import '../../data/services/data_service.dart';
import '../widgets/glossy_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  final DataService _dataService = DataService();

  String _jenisKelamin = 'L';

  int? _selectedBatchId;
  int? _selectedTrainingId;

  bool _isLoading = false;
  bool _obscurePassword = true;

  late Future<List<Map<String, dynamic>>> _batchesFuture;
  late Future<List<Map<String, dynamic>>> _trainingsFuture;

  @override
  void initState() {
    super.initState();
    _batchesFuture = _dataService.getBatches();
    _trainingsFuture = _dataService.getTrainings();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _authService.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      jenisKelamin: _jenisKelamin,
      batchId: _selectedBatchId,
      trainingId: _selectedTrainingId,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Registrasi berhasil'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Registrasi gagal'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Buat Akun Baru', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),

      body: GlossyBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Lengkapi Data Diri.',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Isi formulir di bawah ini untuk mendaftar pelatihan.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 32),
                GlossyCard(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Color(0xFF1E293B)),
                          decoration: InputDecoration(
                            hintText: 'Nama Lengkap',
                            prefixIcon: const Icon(Icons.person_outline),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nama wajib diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Color(0xFF1E293B)),
                          decoration: InputDecoration(
                            hintText: 'Email address',
                            prefixIcon: const Icon(Icons.email_outlined),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email wajib diisi';
                            }
                            if (!value.contains('@')) {
                              return 'Email tidak valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          style: const TextStyle(color: Color(0xFF1E293B)),
                          decoration: InputDecoration(
                            hintText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: const Color(0xFF9CA3AF),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password wajib diisi';
                            }
                            if (value.length < 6) {
                              return 'Password minimal 6 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        const Text('Jenis Kelamin', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Laki-laki', style: TextStyle(fontSize: 14)),
                                value: 'L',
                                groupValue: _jenisKelamin,
                                contentPadding: EdgeInsets.zero,
                                activeColor: const Color(0xFF1E293B),
                                onChanged: (value) {
                                  if (value != null) setState(() => _jenisKelamin = value);
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Perempuan', style: TextStyle(fontSize: 14)),
                                value: 'P',
                                groupValue: _jenisKelamin,
                                contentPadding: EdgeInsets.zero,
                                activeColor: const Color(0xFF1E293B),
                                onChanged: (value) {
                                  if (value != null) setState(() => _jenisKelamin = value);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // BATCH DROPDOWN
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: _batchesFuture,
                          builder: (context, snapshot) {
                            List<Map<String, dynamic>> batches = [];
                            if (snapshot.hasData) {
                              batches = snapshot.data!;
                            }

                            return DropdownButtonFormField<int>(
                              initialValue: _selectedBatchId,
                              decoration: InputDecoration(
                                hintText: 'Pilih Batch',
                                prefixIcon: const Icon(Icons.group_outlined),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.8),
                              ),
                              isExpanded: true,
                              items: batches.isEmpty
                                  ? []
                                  : batches.map((batch) {
                                      return DropdownMenuItem<int>(
                                        value: int.tryParse(batch['id'].toString()),
                                        child: Text(
                                          batch['batch_ke'] != null
                                              ? 'Angkatan ${batch['batch_ke']}'
                                              : 'Batch ${batch['id']}',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                              onChanged: batches.isEmpty
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _selectedBatchId = value;
                                      });
                                    },
                              validator: (value) => value == null ? 'Pilih batch' : null,
                              hint: Text(
                                snapshot.connectionState == ConnectionState.waiting
                                    ? 'Memuat data batch...'
                                    : (batches.isEmpty ? 'Gagal memuat batch' : 'Pilih batch'),
                                style: const TextStyle(color: Color(0xFF9CA3AF)),
                              ),
                              icon: const Icon(Icons.arrow_drop_down_outlined, color: Color(0xFF9CA3AF)),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        // TRAINING DROPDOWN
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: _trainingsFuture,
                          builder: (context, snapshot) {
                            List<Map<String, dynamic>> trainings = [];
                            if (snapshot.hasData) {
                              trainings = snapshot.data!;
                            }

                            return DropdownButtonFormField<int>(
                              initialValue: _selectedTrainingId,
                              decoration: InputDecoration(
                                hintText: 'Pilih Program Pelatihan',
                                prefixIcon: const Icon(Icons.model_training_outlined),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.8),
                              ),
                              isExpanded: true,
                              items: trainings.isEmpty
                                  ? []
                                  : trainings.map((training) {
                                      return DropdownMenuItem<int>(
                                        value: int.tryParse(training['id'].toString()),
                                        child: Text(
                                          training['title']?.toString() ?? 'Training ${training['id']}',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                              onChanged: trainings.isEmpty
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _selectedTrainingId = value;
                                      });
                                    },
                              validator: (value) => value == null ? 'Pilih training' : null,
                              hint: Text(
                                snapshot.connectionState == ConnectionState.waiting
                                    ? 'Memuat data training...'
                                    : (trainings.isEmpty ? 'Gagal memuat training' : 'Pilih training'),
                                style: const TextStyle(color: Color(0xFF9CA3AF)),
                              ),
                              icon: const Icon(Icons.arrow_drop_down_outlined, color: Color(0xFF9CA3AF)),
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8EC5FC),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('DAFTAR SEKARANG'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

