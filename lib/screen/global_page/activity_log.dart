import 'package:flutter/material.dart';
import 'package:fotoloca/widget/log_activity_skeleton.dart';
import 'package:intl/intl.dart';
// Pastikan path import service & skeleton lu bener ya bang
import 'package:fotoloca/services/activity_log_services.dart';

class ActivityLogScreen extends StatefulWidget {
  final int? userId;
  final String? userName;

  const ActivityLogScreen({super.key, this.userId, this.userName});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

// Menggunakan SingleTickerProviderStateMixin agar vsync: this tidak error
class _ActivityLogScreenState extends State<ActivityLogScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<dynamic> _logs = [];

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    setState(() => _isLoading = true);

    // Memanggil service dengan parameter userId (bisa null kalau akses umum)
    final result = await ActivityLogServices().getLogs(userId: widget.userId);

    if (mounted) {
      if (result['success']) {
        setState(() {
          _logs = result['data'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal memuat log'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Fungsi format tanggal sesuai desain "Sekarang, Jam" atau "Kemarin, Jam"
  String _formatLogDate(String dateStr) {
    try {
      DateTime logDate = DateTime.parse(dateStr).toLocal();
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime yesterday = today.subtract(const Duration(days: 1));
      DateTime aDate = DateTime(logDate.year, logDate.month, logDate.day);

      String timeStr = DateFormat('HH.mm').format(logDate);

      if (aDate == today) {
        return "Sekarang, $timeStr";
      } else if (aDate == yesterday) {
        return "Kemarin, $timeStr";
      } else {
        return "${DateFormat('dd MMM yyyy').format(logDate)}, $timeStr";
      }
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Judul dinamis: Jika ada userName, tampilin nama penggunanya
    String title = widget.userName != null
        ? 'Log Aktivitas ${widget.userName}'
        : 'Log Aktivitas';

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const ActivityLogSkeleton() // Memanggil widget skeleton saat loading
          : RefreshIndicator(
              onRefresh: _fetchLogs,
              color: Colors.black87,
              child: _logs.isEmpty
                  ? const Center(
                      child: Text(
                        "Belum ada aktivitas.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      itemCount: _logs.length,
                      separatorBuilder: (context, index) => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Divider(
                          color: Color(0xFFEEEEEE),
                          thickness: 1,
                          height: 1,
                        ),
                      ),
                      itemBuilder: (context, index) {
                        final log = _logs[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Waktu (Sekarang, 20.35)
                            Text(
                              _formatLogDate(log['created_at']),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Isi Deskripsi Aktivitas
                            Text(
                              log['description'] ?? '-',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4A4A4A),
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
    );
  }
}
