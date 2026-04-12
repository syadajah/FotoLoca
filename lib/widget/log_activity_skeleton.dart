import 'package:flutter/material.dart';

class ActivityLogSkeleton extends StatefulWidget {
  const ActivityLogSkeleton({super.key});

  @override
  State<ActivityLogSkeleton> createState() => _ActivityLogSkeletonState();
}

// PERBAIKAN DI SINI:
// Tambahkan "with SingleTickerProviderStateMixin"
// Inilah yang membuat "vsync: this" bisa bekerja
class _ActivityLogSkeletonState extends State<ActivityLogSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    // Setup animasi kelap-kelip (pulse)
    _controller = AnimationController(
      vsync: this, // SEKARANG "this" TIDAK AKAN ERROR
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _opacity = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    // Jangan lupa matikan animasi saat widget dihancurkan
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        itemCount: 7, // Nampilin 7 skeleton item ke bawah
        separatorBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Divider(color: Colors.grey.shade300, thickness: 1, height: 1),
        ),
        itemBuilder: (context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Skeleton untuk Tanggal (Kiri Atas)
              Container(
                width: 100,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 10),

              // Skeleton untuk Deskripsi Log (Baris 1 - Panjang)
              Container(
                width: double.infinity,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 6),

              // Skeleton untuk Deskripsi Log (Baris 2 - Lebih Pendek)
              Container(
                width:
                    MediaQuery.of(context).size.width * 0.6, // 60% lebar layar
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
