import 'package:flutter/material.dart';

class InvoiceScreenKasir extends StatelessWidget {
  // Udah gak butuh Stateful karena datanya langsung ready
  final Map<String, dynamic> productData;
  final Map<String, dynamic> transactionData;
  final String categoryName;

  const InvoiceScreenKasir({
    super.key,
    required this.productData,
    required this.transactionData,
    required this.categoryName,
  });

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

  @override
  Widget build(BuildContext context) {
    // 1. Ekstrak Data Dasar
    final String imageUrl = productData['foto'] ?? '';
    final String namaProduk = productData['nama_produk'] ?? 'Nama Produk';
    final int hargaProduk =
        int.tryParse(productData['harga_produk'].toString()) ?? 0;

    // 2. Ekstrak Data Transaksi (SEKARANG NAMA KASIR DIAMBIL DARI SINI)
    // Asumsinya kolom nama di tabel users Laravel lu adalah 'name'
    final String namaKasir = transactionData['user'] != null
        ? transactionData['user']['name']
        : 'Kasir';
    final String namaPelanggan = transactionData['nama_pelanggan'] ?? '-';
    final String jadwal = transactionData['jadwal'] ?? '-';
    final int uangBayar =
        int.tryParse(transactionData['uang_bayar'].toString()) ?? 0;
    final int uangKembali =
        int.tryParse(transactionData['uang_kembali'].toString()) ?? 0;
    final String kodeUnik = transactionData['nomor_unik'] ?? 'XXX-XXX';

    // 3. Ekstrak Data Add-Ons
    final List<dynamic> addons = transactionData['addons'] ?? [];

    // 4. Hitung Grand Total
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
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
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

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24.0),
        color: const Color(0xFFF9F9F9),
        child: OutlinedButton.icon(
          onPressed: () {
            print("Proses cetak struk via bluetooth thermal printer...");
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: BorderSide(color: Colors.grey.shade300, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            backgroundColor: Colors.white,
          ),
          icon: const Icon(Icons.print, color: Colors.black54),
          label: const Text(
            "Cetak Struk",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
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
                            errorBuilder: (_, _, _) =>
                                _buildPlaceholderImage(),
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
                          categoryName,
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
            _buildDataRow(
              "Kasir",
              namaKasir,
            ), // SEKARANG NAMPILIN NAMA KASIR ASLI
            _buildDataRow("Nama Pelanggan", namaPelanggan),
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

            // --- 7. TIPS BAWAH ---
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
