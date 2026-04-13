import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// ==========================================================
// 1. KELAS UTAMA: USER CARD
// ==========================================================
class UserCard extends StatelessWidget {
  final String name;
  final String username;
  final String role;
  final bool isActive;
  final bool isReadOnly; // <-- TAMBAHAN BARU
  final VoidCallback onHistoryTap;
  final VoidCallback? onTap;

  const UserCard({
    super.key,
    required this.name,
    required this.username,
    required this.role,
    required this.isActive,
    this.isReadOnly = false, // <-- Default false
    required this.onHistoryTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        decoration: BoxDecoration(
          // Kalau ReadOnly (Kasir), warnanya dibikin agak gelap dikit biar beda
          color: isReadOnly ? Colors.grey.shade200 : const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Row(
          children: [
            // --- BAGIAN KIRI (Nama & Username) ---
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      // Teks agak dim kalau read only
                      color: isReadOnly ? Colors.black54 : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    username,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // --- BAGIAN TENGAH (Role) ---
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Role",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role.isNotEmpty
                        ? role[0].toUpperCase() +
                              role.substring(1).toLowerCase()
                        : '-',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isReadOnly ? Colors.black54 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // --- BAGIAN KANAN (Status & Icon History) ---
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 8,
                  ),
                  color: Colors.transparent,
                  child: Text(
                    isActive ? "Aktif" : "Nonaktif",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isActive
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFB71C1C),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                // Icon History tetep bisa diklik walaupun read-only (opsional, sesuaikan logikamu)
                IconButton(
                  onPressed: onHistoryTap,
                  icon: const Icon(Icons.history, color: Colors.grey, size: 26),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// 2. KELAS KEDUA: SKELETON LOADING (Tetap sama)
// ==========================================================
class UserCardSkeleton extends StatelessWidget {
  const UserCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 100, height: 16, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(width: 60, height: 12, color: Colors.white),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 30, height: 12, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(width: 50, height: 14, color: Colors.white),
                ],
              ),
            ),
            Container(width: 50, height: 16, color: Colors.white),
            const SizedBox(width: 15),
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
