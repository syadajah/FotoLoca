import 'package:flutter/material.dart';
import 'package:fotoloca/screen/admin/users/edit_users_admin.dart';
import 'package:fotoloca/services/user_services.dart';
import 'package:fotoloca/utils/app_colors.dart';
import 'package:fotoloca/widget/custom_animated_switch.dart';
import 'package:fotoloca/widget/custom_textfield.dart';

class DetailUsersAdmin extends StatefulWidget {
  final Map<String, dynamic> userData;

  const DetailUsersAdmin({super.key, required this.userData});

  @override
  State<DetailUsersAdmin> createState() => _DetailUsersAdminState();
}

class _DetailUsersAdminState extends State<DetailUsersAdmin> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late bool _isActive;
  bool _isLoadingToggle = false;

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

    // FIX 1: Pake 'is_active' sesuai database Laravel lu
    _isActive =
        widget.userData['is_active'] == 1 ||
        widget.userData['is_active'] == true;
  }

  Future<void> _changedStatus() async {
    setState(() => _isLoadingToggle = true);
    final result = await UserServices().toggleUserStatus(widget.userData['id']);

    if (!mounted) return;

    if (result['success']) {
      setState(() {
        _isActive = !_isActive;
        _isLoadingToggle = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() => _isLoadingToggle = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      barrierDismissible:
          false, // User nggak bisa tutup pop-up sembarangan pas lagi loading
      builder: (context) {
        bool isDeleting = false; // Variabel loading khusus untuk pop-up ini

        return StatefulBuilder(
          builder: (context, setStateDialog) {
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
                      Icons.warning_amber_rounded,
                      color: Colors.redAccent,
                      size: 50,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Hapus Pengguna?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Apakah kamu yakin ingin menghapus pengguna "${widget.userData['name']}"?',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // --- TOMBOL BATAL ---
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isDeleting
                                ? null
                                : () => Navigator.pop(context),
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

                        // --- TOMBOL HAPUS ---
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isDeleting
                                ? null
                                : () async {
                                    // 1. Nyalakan loading muter
                                    setStateDialog(() => isDeleting = true);

                                    // 2. Tembak API Laravel
                                    final result = await UserServices()
                                        .deleteUser(widget.userData['id']);

                                    // 3. Matikan loading muter
                                    setStateDialog(() => isDeleting = false);

                                    if (!context.mounted) return;

                                    if (result['success']) {
                                      // Tutup Pop-Up Dialog
                                      Navigator.pop(context);

                                      // Tutup Halaman Detail dan kirim sinyal 'true' ke halaman sebelumnya
                                      Navigator.pop(context, true);

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(result['message']),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } else {
                                      // Kalau gagal, tutup dialog aja, jangan tutup halaman detailnya
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(result['message']),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: isDeleting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text("Hapus"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Detail Pengguna",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
        ),
      ),

      // FIX 3: Tombol pindah ke bottomNavigationBar biar selalu nempel di bawah
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditUsersAdmin(userData: widget.userData),
                    ),
                  );
                  if (result == true) {
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: AppColors.button,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Edit',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _showDeleteConfirmation();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Colors.redAccent, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Hapus',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Nama Pengguna",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              IgnorePointer(
                child: CustomTextfield(
                  hintText: "",
                  controller: _nameController,
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Username",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              IgnorePointer(
                child: CustomTextfield(
                  hintText: "",
                  controller: _usernameController,
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Email",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              IgnorePointer(
                child: CustomTextfield(
                  hintText: "",
                  controller: _emailController,
                ),
              ),
              const SizedBox(height: 20),

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
              const SizedBox(height: 20),

              // FIX 2: Layout Switch ditaruh di DALAM Row bareng teks Status Akun
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween, // Bikin teks di kiri, switch di kanan
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Status Akun",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isActive
                              ? 'Kasir memiliki akses'
                              : 'Akses kasir diblokir',
                          style: TextStyle(
                            color: _isActive ? Colors.green : Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    CustomAnimatedSwitch(
                      value: _isActive,
                      isLoading: _isLoadingToggle,
                      onChanged: (newValue) => _changedStatus(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
