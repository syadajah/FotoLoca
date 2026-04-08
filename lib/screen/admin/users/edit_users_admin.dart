import 'package:flutter/material.dart';
import 'package:fotoloca/services/user_services.dart';
import 'package:fotoloca/widget/custom_textfield.dart';

import '../../../utils/app_colors.dart' show AppColors;

class EditUsersAdmin extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditUsersAdmin({super.key, required this.userData});

  @override
  State<EditUsersAdmin> createState() => _EditUsersAdminState();
}

class _EditUsersAdminState extends State<EditUsersAdmin> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.userData['name'] ?? '--',
    );
    _usernameController = TextEditingController(
      text: widget.userData['username'] ?? '--',
    );
    _emailController = TextEditingController(
      text: widget.userData['email'] ?? '--',
    );

    // FIX 1: Wajib diinisialisasi, dikosongin aja karena password dari DB gak ditampilin
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    // FIX 1: Wajib dibuang dari memori
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSaveConfirmationDialog() {
    // Validasi dasar
    if (_nameController.text.isEmpty || _usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nama dan username wajib diisi"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // FIX 3: Validasi password dipindah ke sini SEBELUM nembak API
    // Kalau password diisi, wajib cek kecocokan konfirmasinya
    if (_passwordController.text.isNotEmpty &&
        _passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi password tidak cocok!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Tampilkan dialog konfirmasi
    showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFFF9F9F9),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.help_outline,
                  color: AppColors.button,
                  size: 50,
                ),
                const SizedBox(height: 15),
                const Text(
                  "Update Pengguna?",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Apakah kamu yakin ingin menyimpan perubahan pada pengguna ini?',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          side: BorderSide(color: Colors.grey.shade400),
                        ),
                        child: const Text(
                          "Batal",
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: AppColors.button,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text("Simpan"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).then((isConfirmed) {
      if (isConfirmed == true) {
        _prosesEditUser();
      }
    });
  }

  Future<void> _prosesEditUser() async {
    setState(() => _isSubmitting = true);

    try {
      final result = await UserServices().updateUser(
        id: widget.userData['id'],
        name: _nameController.text,
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController
            .text, // Bakal otomatis di-handle service kalau kosong
        role: 'kasir', // Pake hardcode 'kasir' sesuai kesepakatan kita
      );

      setState(() => _isSubmitting = false);
      if (!mounted) return;

      if (result['success']) {
        Navigator.pop(context, true); // Bawa nilai true balik ke halaman detail
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memproses data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Pengguna",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        titleSpacing: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 24.0,
              top: 10.0,
              bottom: 10.0,
            ),
            child: ElevatedButton(
              // FIX 2: Benerin nama variabel dan fungsi yang dipanggil
              onPressed: _isSubmitting ? null : _showSaveConfirmationDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A7A7A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Simpan",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Nama Pengguna",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 5),
              CustomTextfield(
                hintText: "Masukkan nama pengguna",
                controller: _nameController,
              ),
              const SizedBox(height: 15),

              const Text(
                "Username",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 5),
              CustomTextfield(
                hintText: "Masukkan Username",
                controller: _usernameController,
              ),
              const SizedBox(height: 15),

              const Text(
                "Email",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 5),
              CustomTextfield(
                hintText: "fotoloca@gmail.com",
                controller: _emailController,
              ),
              const SizedBox(height: 15),

              // Note: Kalau password gak diisi, data lama gak akan berubah
              const Text(
                "Password (Kosongkan jika tidak ingin diubah)",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 5),
              CustomTextfield(
                hintText: 'Masukkan password baru',
                icon: Icons.lock,
                isObscure: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 15),

              const Text(
                "Konfirmasi Password",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 5),
              CustomTextfield(
                hintText: 'Masukkan konfirmasi password',
                icon: Icons.lock,
                isObscure: true,
                controller: _confirmPasswordController,
              ),
              const SizedBox(height: 15),

              const Text("Role", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 5),
              TextField(
                enabled: false,
                decoration: InputDecoration(
                  hintText: 'Kasir',
                  prefixIcon: const Icon(
                    Icons.verified_user,
                    color: Colors.grey,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
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
