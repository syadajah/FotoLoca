import 'package:flutter/material.dart';
import 'package:fotoloca/screen/global_page/activity_log.dart';
import 'package:fotoloca/screen/admin/users/create_users_admin.dart';
import 'package:fotoloca/screen/admin/users/detail_users_admin.dart';
import 'package:fotoloca/services/user_services.dart';
import 'package:fotoloca/utils/app_colors.dart';
import 'package:fotoloca/widget/custom_button.dart';
import 'package:fotoloca/widget/custom_textfield.dart';
import 'package:fotoloca/widget/user_card.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:iconify_flutter/iconify_flutter.dart';

class UsersScreenAdmin extends StatefulWidget {
  const UsersScreenAdmin({super.key});

  @override
  State<UsersScreenAdmin> createState() => _UsersScreenAdminState();
}

class _UsersScreenAdminState extends State<UsersScreenAdmin> {
  final UserServices _userServices = UserServices();
  late Future<List<dynamic>> _usersFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _usersFuture = _userServices.getUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 24.0,
            bottom: 0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const SizedBox(height: 24),

              // --- BAGIAN SEARCH & HISTORY ---
              Row(
                children: [
                  Expanded(
                    child: CustomTextfield(
                      hintText: "Cari pengguna...",
                      icon: Icons.search,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value; // Update pencarian
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 5),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ActivityLogScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.history,
                      color: AppColors.button,
                      size: 24,
                    ),
                    tooltip: 'Log aktivitas',
                    style: IconButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFFE0E0E0),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- TOMBOL TAMBAH PENGGUNA ---
              CustomButton(
                text: 'Tambah pengguna baru',
                onPressed: () async {
                  // Tunggu sampai halaman create ditutup
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          const CreateUsersAdmin(),
                    ),
                  );
                  // Kalau baliknya bawa data "true" (berhasil save), refresh list!
                  if (result == true) {
                    _refreshData();
                  }
                },
                hasStroke: true,
                textColor: Colors.grey,
                backgroundColor: AppColors.background,
                icon: const Iconify(
                  Mdi.plus,
                  color: AppColors.button,
                  size: 20,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Pengguna',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),

              // --- LIST VIEW DENGAN FUTURE BUILDER ---
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: _usersFuture,
                  builder: (context, snapshot) {
                    // 1. KONDISI LOADING: TAMPILIN SKELETON
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: 7,
                        itemBuilder: (context, index) =>
                            const UserCardSkeleton(),
                      );
                    }
                    // 2. KONDISI ERROR
                    else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Gagal memuat data: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    // 3. KONDISI KOSONG
                    else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'Belum ada pengguna.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    // 4. DATA READY & FITUR SEARCH
                    final allUsers = snapshot.data!;
                    final kasirUsers = allUsers.where((user) {
                      final role = (user['role'] ?? '')
                          .toString()
                          .toLowerCase();
                      return role == 'kasir';
                    }).toList();

                    if (kasirUsers.isEmpty) {
                      return const Center(
                        child: Text(
                          'Belum ada pengguna. \nSilahkan tambahkan pengguna baru.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    final query = _searchQuery.toLowerCase();
                    final filteredUsers = kasirUsers.where((user) {
                      if (query.isEmpty)
                        return true; // Kalau gak ngetik apa-apa, lolosin semua

                      final name = (user['name'] ?? '')
                          .toString()
                          .toLowerCase();
                      final username = (user['username'] ?? '')
                          .toString()
                          .toLowerCase();
                      return name.contains(query) || username.contains(query);
                    }).toList();

                    // 7. CEK HASIL PENCARIAN
                    // Kalau nyari nama tapi gak nemu
                    if (filteredUsers.isEmpty) {
                      return const Center(
                        child: Text(
                          "Pengguna tidak ditemukan",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        // Ambil status aktif
                        final bool isActive =
                            user['is_active'] == 1 || user['is_active'] == true;

                        return UserCard(
                          name: user['name'] ?? 'Unknown',
                          username: user['username'] ?? 'Unknown',
                          role: user['role'] ?? 'Kasir',
                          isActive: isActive,
                          onHistoryTap: () {
                           Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ActivityLogScreen(
                                  userId: user['id'], // Kirim ID user spesifik
                                  userName: user['name'], // Kirim nama buat judul
                                ),
                              ),
                            );
                          },
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailUsersAdmin(userData: user),
                              ),
                            );
                            _refreshData();
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
