import 'package:flutter/material.dart';

import '../../data/services/auth_service.dart';
import '../../data/services/data_service.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Akun Baru', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Lengkapi Data Diri',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Isi formulir di bawah ini untuk mendaftar pelatihan',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Lengkap',
                            prefixIcon: Icon(Icons.person_outline),
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
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
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
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: Colors.grey.shade600,
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
                        const Text('Jenis Kelamin', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Laki-laki', style: TextStyle(fontSize: 14)),
                                value: 'L',
                                groupValue: _jenisKelamin,
                                contentPadding: EdgeInsets.zero,
                                activeColor: colorScheme.primary,
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
                                activeColor: colorScheme.primary,
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
                              decoration: const InputDecoration(
                                labelText: 'Pilih Batch',
                                prefixIcon: Icon(Icons.group_outlined),
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
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              icon: const Icon(Icons.arrow_drop_down_circle_outlined),
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
                              decoration: const InputDecoration(
                                labelText: 'Pilih Program Pelatihan',
                                prefixIcon: Icon(Icons.model_training_outlined),
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
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              icon: const Icon(Icons.arrow_drop_down_circle_outlined),
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
