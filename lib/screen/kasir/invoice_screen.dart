import 'package:flutter/material.dart';
import 'package:fotoloca/services/transaction_services.dart';

class InvoiceScreenKasir extends StatefulWidget {
  final Map<String, dynamic> productData;
  final Map<String, dynamic> transactionData;
  final String categoryName;

  const InvoiceScreenKasir({
    super.key,
    required this.productData,
    required this.transactionData,
    required this.categoryName,
  });

  @override
  State<InvoiceScreenKasir> createState() => _InvoiceScreenKasirState();
}

class _InvoiceScreenKasirState extends State<InvoiceScreenKasir> {
  bool _isSendingEmail = false;

  // Helper Format Rupiah
  String formatRupiah(int number) {
    String numStr = number.toString();
    String result = '';
    int count = 0;
    for (int i = numStr.length - 1; i >= 0; i--) {
      result = numStr[i] + result;
      count++;
      if (count % 3 == 0 && i != 0) {
        result = '.$result';
      }
    }
    return 'Rp $result';
  }

  // Helper Format Tanggal
  String formatDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length != 3) return dateStr;

      final months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Ags',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      final monthIndex = int.parse(parts[1]);
      return "${parts[2]} ${months[monthIndex]} ${parts[0]}";
    } catch (e) {
      return dateStr;
    }
  }

  // Fungsi Eksekusi API Kirim Email
  Future<void> _sendEmail() async {
    final emailPelanggan = widget.transactionData['email_pelanggan'];

    // Cek di awal kalau email kosong
    if (emailPelanggan == null || emailPelanggan.toString().trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada email pelanggan pada transaksi ini.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSendingEmail = true);

    final txId = int.tryParse(widget.transactionData['id'].toString()) ?? 0;

    final result = await TransactionServices().sendInvoiceToEmail(txId);

    if (mounted) {
      setState(() => _isSendingEmail = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );
    }
  }

  // --- DIALOG LOADING SAAT PRINT ---
  void _showPrintingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // User tidak bisa klik luar untuk close
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5A5A5A)),
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Sedang menyiapkan struk...",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                "Mohon tunggu sebentar",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ekstrak Data dari widget (harus pakai widget. karena sekarang Stateful)
    final String imageUrl = widget.productData['foto'] ?? '';
    final String namaProduk =
        widget.productData['nama_produk'] ?? 'Nama Produk';
    final int hargaProduk =
        int.tryParse(widget.productData['harga_produk'].toString()) ?? 0;

    final String namaKasir = widget.transactionData['user'] != null
        ? widget.transactionData['user']['name']
        : 'Kasir';
    final String namaPelanggan =
        widget.transactionData['nama_pelanggan'] ?? '-';
    final String emailPelanggan =
        widget.transactionData['email_pelanggan'] ?? 'Tidak dicantumkan';
    final String jadwal = widget.transactionData['jadwal'] ?? '-';
    final int uangBayar =
        int.tryParse(widget.transactionData['uang_bayar'].toString()) ?? 0;
    final int uangKembali =
        int.tryParse(widget.transactionData['uang_kembali'].toString()) ?? 0;
    final String kodeUnik = widget.transactionData['nomor_unik'] ?? 'XXX-XXX';
    final List<dynamic> addons = widget.transactionData['addons'] ?? [];

    int grandTotal = hargaProduk;
    for (var addon in addons) {
      grandTotal += int.tryParse(addon['harga_addon'].toString()) ?? 0;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        title: const Text(
          "Invoice",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),

      // TOMBOL BAWAH (Sekarang ada 2: Cetak & Kirim Email)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24.0),
        color: const Color(0xFFF9F9F9),
        child: Row(
          children: [
            // Tombol Cetak (Kiri)
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () async {
                  // 1. Validasi ID Transaksi
                  final txId = int.tryParse(
                    widget.transactionData['id'].toString(),
                  );

                  if (txId == null || txId == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ID Transaksi tidak valid.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // 2. Tampilkan loading dialog
                  _showPrintingDialog(context);

                  try {
                    // 3. Panggil service print
                    final result = await TransactionServices().printTransaction(
                      txId,
                    );

                    // 4. Tutup dialog jika widget masih mounted
                    if (mounted) {
                      Navigator.of(context).pop(); // Close dialog loading

                      // 5. Tampilkan result ke user
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result['message']),
                          backgroundColor: result['success']
                              ? Colors.green
                              : Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );

                      // Opsional: Jika sukses, bisa auto-back setelah 2 detik
                      if (result['success']) {
                        await Future.delayed(const Duration(seconds: 2));
                        if (mounted)
                          Navigator.of(
                            context,
                          ).pop(); // Kembali ke screen sebelumnya
                      }
                    }
                  } catch (e) {
                    // Handle error tak terduga
                    if (mounted) {
                      Navigator.of(context).pop(); // Pastikan dialog ditutup
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Terjadi kesalahan: ${e.toString()}'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  backgroundColor: Colors.white,
                ),
                child: const Icon(Icons.print, color: Colors.black54),
              ),
            ),
            const SizedBox(width: 15),
            // Tombol Kirim Email (Kanan)
            Expanded(
              flex: 3,
              child: ElevatedButton.icon(
                onPressed: _isSendingEmail ? null : _sendEmail,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF5A5A5A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: _isSendingEmail
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.email_outlined, color: Colors.white),
                label: Text(
                  _isSendingEmail ? "Mengirim..." : "Kirim ke Email",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. CARD PAKET UTAMA ---
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            width: 100,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _buildPlaceholderImage(),
                          )
                        : _buildPlaceholderImage(),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.categoryName,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          namaProduk,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            formatRupiah(hargaProduk),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- 2. LIST ADD-ONS ---
            if (addons.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                "Layanan Tambahan",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: addons.map((addon) {
                    int addOnPrice =
                        int.tryParse(addon['harga_addon'].toString()) ?? 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              addon['nama_addon'],
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Text(
                            "+ ${formatRupiah(addOnPrice)}",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // --- 3. TOTAL TAGIHAN ---
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF5A5A5A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Tagihan",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    formatRupiah(grandTotal),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- 4. SECTION DATA ---
            const Text(
              "Data",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),
            _buildDataRow("Kasir", namaKasir),
            _buildDataRow("Pelanggan", namaPelanggan),
            _buildDataRow("Email", emailPelanggan), // Tambah info email di UI
            _buildDataRow("Jadwal", formatDate(jadwal)),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(color: Colors.grey, thickness: 0.5),
            ),

            // --- 5. SECTION PEMBAYARAN ---
            const Text(
              "Pembayaran",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),
            _buildDataRow("Uang Bayar", formatRupiah(uangBayar)),
            _buildDataRow("Kembalian", formatRupiah(uangKembali)),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(color: Colors.grey, thickness: 0.5),
            ),
            const SizedBox(height: 10),

            // --- 6. SECTION KODE UNIK ---
            const Center(
              child: Text(
                "Kode Unik",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Center(
              child: Text(
                kodeUnik,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // --- 7. TIPS BAWAH (DITAMBAHKAN KEMBALI) ---
            const Text(
              "Tips:",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("1. ", style: TextStyle(fontSize: 12, color: Colors.grey)),
                Expanded(
                  child: Text(
                    "Silahkan berikan kode unik ini sebagai identitas pelanggan ketika mengambil hasil foto.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("2. ", style: TextStyle(fontSize: 12, color: Colors.grey)),
                Expanded(
                  child: Text(
                    "Atau cetak Invoice ini menjadi struk dan berikan kepada pelanggan, dibutuhkan untuk mengambil pesanan foto.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 100,
      height: 70,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.image_not_supported, color: Colors.grey),
      ),
    );
  }
}
