import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fotoloca/services/transaction_services.dart';
import 'package:fotoloca/widget/history_skeleton_list.dart';
// --- TAMBAHAN 1: Import Secure Storage ---
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fotoloca/screen/kasir/invoice_screen.dart';

class HistoryTransaction extends StatefulWidget {
  const HistoryTransaction({super.key});

  @override
  State<HistoryTransaction> createState() => _HistoryTransactionState();
}

class _HistoryTransactionState extends State<HistoryTransaction> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<dynamic> _transactions = [];
  bool _isLoading = true;
  int _fetchId = 0;

  DateTime? _startDate;
  DateTime? _endDate;

  // --- TAMBAHAN 2: Variabel penyimpan role ---
  String _userRole = 'kasir'; // Default kita set kasir untuk keamanan

  @override
  void initState() {
    super.initState();
    _loadUserRole(); // Panggil fungsi cek role
    _fetchHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // --- TAMBAHAN 3: Fungsi narik role dari storage ---
  Future<void> _loadUserRole() async {
    const storage = FlutterSecureStorage();
    final role = await storage.read(
      key: 'user_role',
    ); // Pastikan key-nya sama dengan waktu login

    if (mounted) {
      setState(() {
        _userRole = role ?? 'kasir';
      });
    }
  }

  // --- FUNGSI TARIK DATA DARI API ---
  Future<void> _fetchHistory() async {
    _fetchId++; // Tiap kali fungsi dipanggil, nomor antrean naik
    final int currentFetchId = _fetchId; // Simpan nomor antrean saat ini

    setState(() => _isLoading = true);

    String? startStr = _startDate != null
        ? "${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}"
        : null;
    String? endStr = _endDate != null
        ? "${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}"
        : null;

    final data = await TransactionServices().getTransactions(
      search: _searchController.text,
      startDate: startStr,
      endDate: endStr,
    );

    if (!mounted || currentFetchId != _fetchId) return;

    setState(() {
      _transactions = data;
      _isLoading = false;
    });
  }

  // --- FUNGSI PILIH TANGGAL AWAL ---
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: _endDate ?? DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        _endDate = picked; // Otomatis filter 1 hari
      });
      _fetchHistory();
    }
  }

  // --- FUNGSI PILIH TANGGAL AKHIR ---
  Future<void> _selectEndDate(BuildContext context) async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih Awal Tanggal terlebih dahulu!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!,
      firstDate: _startDate!,
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() => _endDate = picked);
      _fetchHistory();
    }
  }

  // --- FUNGSI RESET TANGGAL ---
  void _resetDates() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    _fetchHistory();
  }

  // --- FUNGSI EKSEKUSI EXPORT (DOWNLOAD) ---
  Future<void> _executeDownload(String formatType) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    String? startStr = _startDate != null
        ? "${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}"
        : null;
    String? endStr = _endDate != null
        ? "${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}"
        : null;

    final result = await TransactionServices().downloadLaporan(
      startDate: startStr,
      endDate: endStr,
      type: formatType,
    );

    if (mounted) Navigator.pop(context); // Tutup loading

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  // --- POPUP PILIH FORMAT CETAK ---
  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Cetak Laporan Transaksi",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Pilih format file laporan yang ingin Anda unduh.",
                style: TextStyle(color: Colors.grey, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildExportOptionBtn(
                    icon: Icons.table_view_rounded,
                    color: Colors.green,
                    title: "Excel",
                    onTap: () {
                      Navigator.pop(context);
                      _executeDownload('excel');
                    },
                  ),
                  _buildExportOptionBtn(
                    icon: Icons.picture_as_pdf_rounded,
                    color: Colors.redAccent,
                    title: "PDF",
                    onTap: () {
                      Navigator.pop(context);
                      _executeDownload('pdf');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // WIDGET TOMBOL PILIHAN FORMAT
  Widget _buildExportOptionBtn({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- HELPER FORMAT ---
  String formatRupiah(int number) {
    String numStr = number.toString();
    String result = '';
    int count = 0;
    for (int i = numStr.length - 1; i >= 0; i--) {
      result = numStr[i] + result;
      count++;
      if (count % 3 == 0 && i != 0) result = '.$result';
    }
    return 'Rp $result';
  }

  String formatDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length != 3) return dateStr;
      return "${parts[2]}/${parts[1]}/${parts[0]}";
    } catch (e) {
      return dateStr;
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchHistory();
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        title: const Text(
          "Filter Tanggal",
          style: TextStyle(color: Colors.black54, fontSize: 16),
        ),
        automaticallyImplyLeading: false,
      ),

      // --- TAMBAHAN 4: Logika penyembunyian FAB ---
      floatingActionButton: (_userRole == 'admin' || _userRole == 'owner')
          ? FloatingActionButton(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              onPressed: _showExportOptions,
              child: const Icon(Icons.print_rounded, color: Colors.black87),
            )
          : null, // Return null kalau kasir, jadi tombolnya ga digambar

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // --- FILTER TANGGAL DENGAN TOMBOL RESET ---
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectStartDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _startDate != null
                                ? "${_startDate!.day}/${_startDate!.month}/${_startDate!.year}"
                                : "Awal tanggal",
                            style: TextStyle(
                              color: _startDate != null
                                  ? Colors.black87
                                  : Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectEndDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _endDate != null
                                ? "${_endDate!.day}/${_endDate!.month}/${_endDate!.year}"
                                : "---",
                            style: TextStyle(
                              color: _endDate != null
                                  ? Colors.black87
                                  : Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // TOMBOL RESET TANGGAL
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: IconButton(
                    padding: const EdgeInsets.all(10),
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    onPressed: _resetDates,
                    tooltip: 'Reset Filter Tanggal',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // --- KOLOM PENCARIAN ---
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: "Cari nama, nomor unik, atau produk...",
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.cancel,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                          FocusScope.of(context).unfocus();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // --- LIST TRANSAKSI ---
            Expanded(
              child: _isLoading
                  ? const HistorySkeletonList(itemCount: 5)
                  : _transactions.isEmpty
                  ? const Center(
                      child: Text(
                        "Tidak ada data transaksi",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        final tx = _transactions[index];
                        final product = tx['product'] ?? {};
                        final category =
                            product['category'] ?? product['kategori'] ?? {};
                        final user = tx['user'] ?? {};

                        int uangBayar =
                            int.tryParse(tx['uang_bayar'].toString()) ?? 0;
                        int uangKembali =
                            int.tryParse(tx['uang_kembali'].toString()) ?? 0;
                        int totalHarga = uangBayar - uangKembali;

                        String namaKategori =
                            category['nama_kategori'] ?? 'Kategori';
                        String namaKasir = user['name'] ?? 'Kasir (Terhapus)';
                        String nomorUnik = tx['nomor_unik'] ?? 'XXX-XXX';
                        String namaPelanggan =
                            tx['nama_pelanggan'] ?? 'Pelanggan';
                        String namaProduk =
                            product['nama_produk'] ?? 'Produk (Terhapus)';

                        return GestureDetector(
                          onTap: () {
                            // Cek apakah role-nya kasir
                            if (_userRole == 'kasir') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InvoiceScreenKasir(
                                    transactionData: tx,
                                    productData: product,
                                    categoryName: namaKategori,
                                  ),
                                ),
                              );
                            } else {
                              // Munculkan notifikasi jika bukan kasir
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Detail invoice hanya dapat diakses oleh Kasir.',
                                  ),
                                  backgroundColor: Colors
                                      .orange, // Warna orange biar terkesan peringatan, bukan error fatal
                                ),
                              );
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: product['foto'] != null
                                      ? Image.network(
                                          product['foto'],
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) => Container(
                                            width: 80,
                                            height: 80,
                                            color: Colors.grey.shade200,
                                          ),
                                        )
                                      : Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.grey.shade200,
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            namaKategori,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            namaKasir,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "$nomorUnik • $namaPelanggan",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        namaProduk,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            formatDate(tx['jadwal'] ?? '-'),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            formatRupiah(totalHarga),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFD4AF37),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
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
