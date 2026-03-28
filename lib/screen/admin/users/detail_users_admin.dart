import 'package:flutter/material.dart';
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
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Aksi ke halaman Edit
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
                  // Aksi Hapus
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
