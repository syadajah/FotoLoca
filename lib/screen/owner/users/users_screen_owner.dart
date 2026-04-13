import 'package:flutter/material.dart';
import 'package:fotoloca/screen/global_page/activity_log.dart';
import 'package:fotoloca/screen/owner/users/create_users_owner.dart';
import 'package:fotoloca/screen/owner/users/detail_users_owner.dart'; // PASTIIN INI IMPORT FILE BARU
import 'package:fotoloca/services/user_services.dart';
import 'package:fotoloca/utils/app_colors.dart';
import 'package:fotoloca/widget/custom_button.dart';
import 'package:fotoloca/widget/custom_textfield.dart';
import 'package:fotoloca/widget/user_card.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:iconify_flutter/iconify_flutter.dart';

class UsersScreenOwner extends StatefulWidget {
  const UsersScreenOwner({super.key});

  @override
  State<UsersScreenOwner> createState() => _UsersScreenOwnerState();
}

class _UsersScreenOwnerState extends State<UsersScreenOwner> {
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
      body: Padding(
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
            Row(
              children: [
                Expanded(
                  child: CustomTextfield(
                    hintText: "Cari pengguna...",
                    icon: Icons.search,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
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
                    side: const BorderSide(color: Color(0xFFE0E0E0), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            CustomButton(
              text:
                  'Tambah admin baru', // Lebih spesifik karena cm nambah admin
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const CreateUsersOwner(),
                  ),
                );
                if (result == true) {
                  _refreshData();
                }
              },
              hasStroke: true,
              textColor: Colors.grey,
              backgroundColor: AppColors.background,
              icon: const Iconify(Mdi.plus, color: AppColors.button, size: 20),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pengguna Terdaftar',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _usersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: 7,
                      itemBuilder: (context, index) => const UserCardSkeleton(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Gagal memuat data: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'Belum ada pengguna.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  final allUsers = snapshot.data!;

                  // TAMPILKAN ADMIN DAN KASIR
                  final roleFilteredUsers = allUsers.where((user) {
                    final role = (user['role'] ?? '').toString().toLowerCase();
                    return role == 'admin' || role == 'kasir';
                  }).toList();

                  if (roleFilteredUsers.isEmpty) {
                    return const Center(
                      child: Text(
                        'Belum ada admin/kasir.\nSilahkan tambahkan admin baru.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  final query = _searchQuery.toLowerCase();
                  final filteredUsers = roleFilteredUsers.where((user) {
                    if (query.isEmpty) return true;
                    final name = (user['name'] ?? '').toString().toLowerCase();
                    final username = (user['username'] ?? '')
                        .toString()
                        .toLowerCase();
                    return name.contains(query) || username.contains(query);
                  }).toList();

                  if (filteredUsers.isEmpty) {
                    return const Center(
                      child: Text(
                        "Pengguna tidak ditemukan",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      final bool isActive =
                          user['is_active'] == 1 || user['is_active'] == true;
                      final String role = (user['role'] ?? '')
                          .toString()
                          .toLowerCase();

                      return UserCard(
                        name: user['name'] ?? 'Unknown',
                        username: user['username'] ?? 'Unknown',
                        role: role,
                        isActive: isActive,
                        isReadOnly: role == 'kasir', // Kirim status readonly
                        onHistoryTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ActivityLogScreen(
                                userId: user['id'],
                                userName: user['name'],
                              ),
                            ),
                          );
                        },
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailUsersOwner(userData: user),
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
    );
  }
}
