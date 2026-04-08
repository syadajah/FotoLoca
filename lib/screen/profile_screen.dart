import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fotoloca/screen/login.dart'; // Sesuaikan path login lu
import 'package:fotoloca/services/auth_service.dart';
import 'package:fotoloca/services/user_services.dart'; // Pastiin ini ke-import ya!

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Controller buat form edit
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String _headerName = 'Loading...';
  String _headerUsername = 'loading...';
  String _role = '';
  int _userId = 0;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final name = await _storage.read(key: 'user_name') ?? 'Kasir Fotoloca';
    final role = await _storage.read(key: 'user_role') ?? 'kasir';
    final username = await _storage.read(key: 'user_username') ?? 'kasir_user';
    final email = await _storage.read(key: 'user_email') ?? '';
    final idStr = await _storage.read(key: 'user_id') ?? '0';

    setState(() {
      _userId = int.tryParse(idStr) ?? 0;
      _headerName = name;
      _headerUsername = username;
      _role = role;

      _nameController.text = name;
      _usernameController.text = username;
      _emailController.text = email;

      _isLoading = false;
    });
  }

  // =========================================================
  // POPUP ALERT DIALOG KONFIRMASI SIMPAN
  // =========================================================
  void _showSaveConfirmation() {
    // Validasi kosong ditaruh di sini sebelum pop-up muncul
    if (_nameController.text.isEmpty || _usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama dan Username tidak boleh kosong!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Simpan Perubahan?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Apakah kamu yakin ingin memperbarui data profil ini?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Batal & tutup pop-up
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5A5A5A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(context); // Tutup pop-up dulu
                _saveProfile(); // Baru jalanin fungsi simpan ke API
              },
              child: const Text(
                'Ya, Simpan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // POPUP ALERT DIALOG KONFIRMASI LOGOUT
  // =========================================================
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: const [
              Icon(Icons.logout, color: Colors.redAccent),
              SizedBox(width: 10),
              Text(
                'Konfirmasi Logout',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text('Apakah kamu yakin ingin keluar dari akun ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Batal
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(context); // Tutup pop-up
                _logout(); // Eksekusi fungsi logout
              },
              child: const Text(
                'Keluar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- FUNGSI EKSEKUSI API SIMPAN ---
  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    // Panggil UserServices buat update ke Laravel
    final result = await UserServices().updateProfile(
      id: _userId,
      name: _nameController.text,
      username: _usernameController.text,
      email: _emailController.text,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      await _storage.write(key: 'user_name', value: _nameController.text);
      await _storage.write(
        key: 'user_username',
        value: _usernameController.text,
      );
      await _storage.write(key: 'user_email', value: _emailController.text);

      setState(() {
        _headerName = _nameController.text;
        _headerUsername = _usernameController.text;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Profil berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ),
      );
      FocusScope.of(context).unfocus();
    } else {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal memperbarui profil'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- FUNGSI EKSEKUSI API LOGOUT ---
  Future<void> _logout() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    try {
      await AuthService().logout();
    } catch (e) {
      print("Server logout error, lanjut hapus lokal");
    }

    await _storage.deleteAll();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF9F9F9),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF5A5A5A)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // --- HEADER ---
              Center(
                child: Column(
                  children: [
                    Text(
                      _headerName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _headerUsername,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _role.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // --- FORM EDIT ---
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputLabel("Nama"),
                      _buildTextField(
                        _nameController,
                        "Masukkan nama pengguna",
                      ),

                      const SizedBox(height: 20),

                      _buildInputLabel("Username"),
                      _buildTextField(
                        _usernameController,
                        "Masukkan username pengguna",
                      ),

                      const SizedBox(height: 20),

                      _buildInputLabel("Email (Opsional)"),
                      _buildTextField(
                        _emailController,
                        "Masukkan email aktif",
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 30),

                      // --- TOMBOL SIMPAN ---
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          // Panggil ALERT KONFIRMASI SIMPAN di sini
                          onPressed: _isSaving ? null : _showSaveConfirmation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5A5A5A),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Simpan Perubahan",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- TOMBOL LOGOUT ---
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  // Panggil ALERT KONFIRMASI LOGOUT di sini
                  onPressed: _showLogoutConfirmation,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.black54, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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

  // --- HELPER WIDGETS ---
  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.grey, width: 1.5),
        ),
      ),
    );
  }
}
