import 'package:flutter/material.dart';
// PASTIKAN IMPORT SERVICE LU BENER YA
import 'package:fotoloca/services/user_services.dart';
import 'package:fotoloca/utils/app_colors.dart';
import 'package:fotoloca/widget/custom_textfield.dart';

class CreateUsersAdmin extends StatefulWidget {
  const CreateUsersAdmin({super.key});

  @override
  State<CreateUsersAdmin> createState() => CreateUsersAdminState();
}

class CreateUsersAdminState extends State<CreateUsersAdmin> {
  // 1. HAPUS KATA 'final' di sini biar bisa di-setState
  bool _isLoadingSubmit = false;

  // 2. SIAPIN CONTROLLER BUAT NANGKAP KETIKAN
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Role kita hardcode aja karena ini halaman khusus nambah kasir
  final String _role = 'kasir';

  @override
  void dispose() {
    // 3. JANGAN LUPA BERSIHIN MEMORI
    _namaController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 4. FUNGSI SAKTI BUAT NYIMPEN DATA
  Future<void> _simpanUser() async {
    // Validasi 1: Pastikan gak ada yang kosong
    if (_namaController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi data pengguna!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validasi 2: Pastikan password & konfirmasi sama
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi password tidak cocok!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoadingSubmit = true);

    // 5. TEMBAK API VIA SERVICE
    final result = await UserServices().addUser(
      name: _namaController.text,
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      role: _role, // Otomatis jadi kasir
    );

    setState(() => _isLoadingSubmit = false);

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(
        context,
        true,
      ); // Balik ke halaman sebelumnya sambil bawa nilai true
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
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
          "Tambah Pengguna",
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
              // 6. SAMBUNGIN TOMBOL KE FUNGSI
              onPressed: _isLoadingSubmit ? null : _simpanUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A7A7A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: _isLoadingSubmit
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
              // --- NAMA PENGGUNA ---
              const Text(
                "Nama Pengguna",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 5),
              CustomTextfield(
                hintText: "Masukkan nama pengguna",
                controller: _namaController, // Colok kabel controller
              ),
              const SizedBox(height: 15),

              // --- USERNAME ---
              const Text(
                "Username",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 5),
              CustomTextfield(
                hintText: "Masukkan Username",
                controller: _usernameController, // Colok kabel controller
              ),
              const SizedBox(height: 15),

              // --- USERNAME ---
              const Text(
                "Email",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 5),
              CustomTextfield(
                hintText: "fotoloca@gmail.com",
                controller: _emailController, // Colok kabel controller
              ),
              const SizedBox(height: 15),

              // --- PASSWORD ---
              const Text(
                "Password",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 5),
              CustomTextfield(
                hintText: 'Masukkan password',
                icon: Icons.lock,
                isObscure: true,
                controller: _passwordController, // Colok kabel controller
              ),
              const SizedBox(height: 15),

              // --- KONFIRMASI PASSWORD ---
              const Text(
                "Konfirmasi Password",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 5),
              CustomTextfield(
                hintText: 'Masukkan konfirmasi password',
                icon: Icons.lock,
                isObscure: true,
                controller:
                    _confirmPasswordController, // Colok kabel controller
              ),
              const SizedBox(height: 15),

              // --- READONLY ROLE KASIR ---
              const Text("Role", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 5),
              // Karena ini readonly, mending disabled aja TextField-nya biar kerasa gak bisa diketik
              TextField(
                enabled: false,
                decoration: InputDecoration(
                  hintText: 'Kasir',
                  prefixIcon: const Icon(
                    Icons.verified_user,
                    color: Colors.grey,
                  ),
                  filled: true,
                  fillColor:
                      Colors.grey.shade200, // Warna agak gelap nandain readonly
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
