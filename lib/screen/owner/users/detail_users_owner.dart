import 'package:flutter/material.dart';
import 'package:fotoloca/screen/owner/users/edit_users_owner.dart';
import 'package:fotoloca/services/user_services.dart';
import 'package:fotoloca/utils/app_colors.dart';
import 'package:fotoloca/widget/custom_animated_switch.dart';
import 'package:fotoloca/widget/custom_textfield.dart';

class DetailUsersOwner extends StatefulWidget {
  final Map<String, dynamic> userData;

  const DetailUsersOwner({super.key, required this.userData});

  @override
  State<DetailUsersOwner> createState() => _DetailUsersOwnerState();
}

class _DetailUsersOwnerState extends State<DetailUsersOwner> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late bool _isActive;
  bool _isLoadingToggle = false;

  // Variabel buat nentuin ini Kasir atau bukan
  late bool _isKasir;

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
    _isActive =
        widget.userData['is_active'] == 1 ||
        widget.userData['is_active'] == true;

    // Cek rolenya di sini
    final role = (widget.userData['role'] ?? '').toString().toLowerCase();
    _isKasir = role == 'kasir';
  }

  Future<void> _changedStatus() async {
    // Kalau kasir, gak boleh ganti status
    if (_isKasir) return;

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
      barrierDismissible: false,
      builder: (context) {
        bool isDeleting = false;
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
                      "Hapus Admin?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Apakah kamu yakin ingin menghapus admin "${widget.userData['name']}"?',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
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
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isDeleting
                                ? null
                                : () async {
                                    setStateDialog(() => isDeleting = true);
                                    final result = await UserServices()
                                        .deleteUser(widget.userData['id']);
                                    setStateDialog(() => isDeleting = false);
                                    if (!context.mounted) return;

                                    if (result['success']) {
                                      Navigator.pop(context);
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
        // LOGIKA 1: Judul AppBar dinamis
        title: Text(
          _isKasir ? "Detail Kasir" : "Detail Admin",
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
        ),
      ),

      // LOGIKA 2: Sembunyikan BottomNavigationBar kalau dia Kasir
      bottomNavigationBar: _isKasir
          ? null // Kasih null biar hilang
          : Container(
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
                                EditUsersOwner(userData: widget.userData),
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _showDeleteConfirmation,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(
                          color: Colors.redAccent,
                          width: 2,
                        ),
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
              // LOGIKA 3: Munculin Banner Warning cuma buat Kasir
              if (_isKasir)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "Mode Read-Only. Data kasir hanya dapat dikelola oleh Admin.",
                          style: TextStyle(color: Colors.black87, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

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
                  hintText: _isKasir
                      ? 'Kasir'
                      : 'Admin', // LOGIKA 4: HintText Dinamis
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              ? 'Pengguna memiliki akses'
                              : 'Akses pengguna diblokir',
                          style: TextStyle(
                            color: _isActive ? Colors.green : Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    // LOGIKA 5: Kalau kasir, tampilkan badge statis. Kalau admin, tampilkan Switch
                    _isKasir
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _isActive
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _isActive ? "Aktif" : "Nonaktif",
                              style: TextStyle(
                                color: _isActive
                                    ? Colors.green.shade800
                                    : Colors.red.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : CustomAnimatedSwitch(
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
