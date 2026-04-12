import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fotoloca/services/dashboard_services.dart';
import 'package:fotoloca/widget/custom_adminhomepage_skeleton.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; // Import untuk parsing tanggal

class HomepageAdmin extends StatefulWidget {
  const HomepageAdmin({super.key});

  @override
  State<HomepageAdmin> createState() => _HomepageAdminState();
}

class _HomepageAdminState extends State<HomepageAdmin> {
  String _adminName = 'Admin';
  bool _isLoading = true;
  Map<String, dynamic> _dashboardData = {};

  // -- Variabel untuk Kalender --
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<DateTime> _bookedDates =
      []; // List untuk menyimpan tanggal dari database

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    const storage = FlutterSecureStorage();
    final name = await storage.read(key: 'user_name');
    if (name != null) setState(() => _adminName = name);

    final result = await DashboardServices().getAdminDashboard();

    if (result['success'] == true) {
      // Parsing data tanggal string ("YYYY-MM-DD") menjadi objek DateTime
      List<DateTime> parsedDates = [];
      if (result['data']['booked_dates'] != null) {
        for (var dateString in result['data']['booked_dates']) {
          try {
            // Sesuaikan format dengan format yang dikirim Laravel (misal: yyyy-MM-dd)
            parsedDates.add(DateFormat('yyyy-MM-dd').parse(dateString));
          } catch (e) {
            print("Gagal parsing tanggal: $dateString");
          }
        }
      }

      setState(() {
        _dashboardData = result['data'];
        _bookedDates = parsedDates; // Simpan ke variable state
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal memuat data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String formatRupiah(int number) {
    String numStr = number.toString();
    String result = '';
    int count = 0;
    for (int i = numStr.length - 1; i >= 0; i--) {
      result = numStr[i] + result;
      count++;
      if (count % 3 == 0 && i != 0) result = '.$result';
    }
    return 'Rp $result,00';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF9F9F9,
      ), // Warna background persis desain
      body: SafeArea(
        child: _isLoading
            ? const AdminSkeleton()
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- HEADER ---
                      Text(
                        'Selamat datang, $_adminName!',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tetap produktif dalam mengelola aplikasi ✨',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 30),

                      // --- CARD 1: INFORMASI PENGGUNA ---
                      const Text(
                        "Informasi Pengguna Berjalan",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8D8D8D),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "Kasir",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "Aktif: ${_dashboardData['kasir']?['aktif'] ?? 0}/${_dashboardData['kasir']?['total'] ?? 0}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              top: 0,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                                child: Image.asset(
                                  'assets/images/amico.png',
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // --- CARD 2: TRANSAKSI BULANAN ---
                      const Text(
                        "Informasi Transaksi Bulanan",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A4A4A),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.account_balance_wallet_outlined,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Total transaksi",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                Text(
                                  "${_dashboardData['transaksi']?['total_transaksi'] ?? 0} Transaksi",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: Text(
                                    "|",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                Text(
                                  formatRupiah(
                                    _dashboardData['transaksi']?['total_pendapatan'] ??
                                        0,
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              (_dashboardData['transaksi']?['persentase'] ??
                                          0) >=
                                      0
                                  ? "Penghasilan bertambah ${_dashboardData['transaksi']?['persentase'] ?? 0}% dari bulan kemarin"
                                  : "Penghasilan menurun ${(_dashboardData['transaksi']?['persentase'] ?? 0).abs()}% dari bulan kemarin",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // --- SECTION 3: KALENDER JADWAL ---
                      const Text(
                        "Jadwal Booking",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: TableCalendar(
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) =>
                              isSameDay(_selectedDay, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          },
                          calendarBuilders: CalendarBuilders(
                            defaultBuilder: (context, day, focusedDay) {
                              // Cek apakah tanggal (day) ada di _bookedDates
                              bool isBooked = _bookedDates.any(
                                (bookedDate) =>
                                    bookedDate.year == day.year &&
                                    bookedDate.month == day.month &&
                                    bookedDate.day == day.day,
                              );

                              if (isBooked) {
                                return Container(
                                  margin: const EdgeInsets.all(4.0),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8.0),
                                    border: Border.all(color: Colors.redAccent),
                                  ),
                                  child: Text(
                                    '${day.day}',
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }
                              return null; // Gunakan tampilan default jika tidak dibooking
                            },
                          ),
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                          ),
                          calendarStyle: CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: Colors.blue.shade200,
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: const BoxDecoration(
                              color: Color(0xFF4A4A4A),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // --- SECTION 4: BUNDLE TERLARIS ---
                      const Text(
                        "Bundle Produk Terlaris",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        child:
                            _dashboardData['top_products'] == null ||
                                _dashboardData['top_products'].isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text("Belum ada transaksi."),
                                ),
                              )
                            : Column(
                                children: List.generate(
                                  _dashboardData['top_products'].length,
                                  (index) {
                                    final item =
                                        _dashboardData['top_products'][index];
                                    final product = item['product'] ?? {};
                                    final category = product['category'] ?? {};

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 15),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.02,
                                            ),
                                            blurRadius: 5,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              product['foto'] ??
                                                  'https://via.placeholder.com/100',
                                              width: 100,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, _, _) =>
                                                  Container(
                                                    width: 100,
                                                    height: 80,
                                                    color: Colors.grey.shade200,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(width: 15),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "#Terlaris ${index + 1}",
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color(
                                                          0xFF4A4A4A,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      category['nama_kategori'] ??
                                                          'Kategori',
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.grey,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  product['nama_produk'] ??
                                                      'Nama Produk',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(height: 15),
                                                Text(
                                                  "${item['total_dipesan']}x Dipesan",
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0xFF4A4A4A),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
